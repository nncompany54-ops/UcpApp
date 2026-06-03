import os
import sys
import paramiko
import zipfile
from stat import S_ISDIR

def zip_dir(dir_path, zip_path):
    print(f"Creating zip archive of {dir_path} at {zip_path}...")
    with zipfile.ZipFile(zip_path, 'w', zipfile.ZIP_DEFLATED) as zipf:
        for root, dirs, files in os.walk(dir_path):
            for file in files:
                file_path = os.path.join(root, file)
                arcname = os.path.relpath(file_path, dir_path)
                zipf.write(file_path, arcname)
    print("Zip archive created successfully.")

# VPS Connection configuration
VPS_IP = '72.62.244.69'
VPS_USER = 'root'
VPS_PASS = 'Moha773836693@'

LOCAL_PROJECT_ROOT = r"d:\course antigravity\UCPApp"
LOCAL_WEB_BUILD_DIR = os.path.join(LOCAL_PROJECT_ROOT, "frontend", "build", "web")

def run_ssh_command(ssh_client, command):
    try:
        print(f"\n[Executing] {command}")
    except UnicodeEncodeError:
        print(f"\n[Executing] {command.encode('ascii', errors='replace').decode('ascii')}")
        
    stdin, stdout, stderr = ssh_client.exec_command(command)
    
    # Read output in real time
    for line in stdout:
        try:
            print(f"  [STDOUT] {line.strip()}")
        except UnicodeEncodeError:
            try:
                clean_line = line.encode(sys.stdout.encoding or 'utf-8', errors='replace').decode(sys.stdout.encoding or 'utf-8')
                print(f"  [STDOUT] {clean_line.strip()}")
            except Exception:
                print(f"  [STDOUT] {line.encode('ascii', errors='replace').decode('ascii').strip()}")
    
    try:
        err_output = stderr.read().decode('utf-8', errors='ignore')
        if err_output:
            try:
                print(f"  [STDERR] {err_output.strip()}")
            except UnicodeEncodeError:
                try:
                    clean_err = err_output.encode(sys.stdout.encoding or 'utf-8', errors='replace').decode(sys.stdout.encoding or 'utf-8')
                    print(f"  [STDERR] {clean_err.strip()}")
                except Exception:
                    print(f"  [STDERR] {err_output.encode('ascii', errors='replace').decode('ascii').strip()}")
    except Exception as e:
        print(f"  [Error reading STDERR] {e}")
    
    return stdout.channel.recv_exit_status()

def sftp_mkdir_recursive(sftp, remote_path):
    sub_dirs = remote_path.split('/')
    current_path = ''
    for sub_dir in sub_dirs:
        if not sub_dir:
            continue
        current_path += '/' + sub_dir
        try:
            sftp.stat(current_path)
        except IOError:
            print(f"[SFTP] Creating remote directory: {current_path}")
            sftp.mkdir(current_path)

def upload_dir_recursive(sftp, local_dir, remote_dir):
    sftp_mkdir_recursive(sftp, remote_dir)
    for entry in os.listdir(local_dir):
        local_path = os.path.join(local_dir, entry)
        remote_path = remote_dir + '/' + entry
        
        if os.path.isdir(local_path):
            upload_dir_recursive(sftp, local_path, remote_path)
        else:
            print(f"[SFTP] Uploading {local_path} -> {remote_path}")
            sftp.put(local_path, remote_path)

def main():
    print("=== Starting VPS Deployment Script ===")
    
    # Establish SSH connection
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    
    try:
        print(f"Connecting to VPS {VPS_IP}...")
        ssh.connect(VPS_IP, username=VPS_USER, password=VPS_PASS, timeout=30)
        print("Connected successfully!")
    except Exception as e:
        print(f"Failed to connect to VPS: {e}")
        sys.exit(1)
        
    # Open SFTP client
    sftp = ssh.open_sftp()
    
    try:
        # Step 1: Install system packages
        print("\n--- Step 1: Updating System Packages and Installing Dependencies ---")
        run_ssh_command(ssh, "export DEBIAN_FRONTEND=noninteractive && apt-get update -y")
        run_ssh_command(ssh, "export DEBIAN_FRONTEND=noninteractive && apt-get install -y python3 python3-pip python3-venv git nginx certbot python3-certbot-nginx -y")
        
        # Step 2: Clone or Pull Github repository
        print("\n--- Step 2: Setting up code repository ---")
        repo_dir = "/var/www/ucp_app"
        stdin, stdout, stderr = ssh.exec_command(f"ls -d {repo_dir}")
        if stdout.channel.recv_exit_status() == 0:
            print("Repository already exists. Pulling latest updates...")
            run_ssh_command(ssh, f"cd {repo_dir} && git reset --hard && git pull")
        else:
            print("Repository does not exist. Cloning...")
            run_ssh_command(ssh, f"git clone https://github.com/nncompany54-ops/UcpApp.git {repo_dir}")
            
        # Step 3: Setup Virtual Environment & Install requirements
        print("\n--- Step 3: Configuring Python virtual environment ---")
        run_ssh_command(ssh, f"python3 -m venv {repo_dir}/backend/venv")
        run_ssh_command(ssh, f"{repo_dir}/backend/venv/bin/pip install --upgrade pip")
        run_ssh_command(ssh, f"{repo_dir}/backend/venv/bin/pip install -r {repo_dir}/backend/requirements.txt")
        
        # Step 4: Write environment file (.env)
        print("\n--- Step 4: Writing .env configuration file ---")
        env_content = (
            "DATABASE_URL=postgresql://postgres.twdukqmcvqhzpzthvglw:moha773836693@aws-1-ap-south-1.pooler.supabase.com:6543/postgres\n"
            "DEBUG=False\n"
            "DJANGO_SECRET_KEY=Moha773836693@SecureUCPAppKey2026\n"
        )
        env_path = f"{repo_dir}/backend/.env"
        with sftp.file(env_path, 'w') as f:
            f.write(env_content)
        print(f"Created .env file at {env_path}")
        
        # Step 5: Django database migrations and static collection
        print("\n--- Step 5: Running Django migrations and collectstatic ---")
        run_ssh_command(ssh, f"{repo_dir}/backend/venv/bin/python {repo_dir}/backend/manage.py collectstatic --noinput")
        run_ssh_command(ssh, f"{repo_dir}/backend/venv/bin/python {repo_dir}/backend/manage.py migrate")
        
        # Step 6: Configure Gunicorn service
        print("\n--- Step 6: Configuring Gunicorn service ---")
        gunicorn_service = (
            "[Unit]\n"
            "Description=gunicorn daemon for UCP Backend\n"
            "After=network.target\n\n"
            "[Service]\n"
            "User=root\n"
            "WorkingDirectory=/var/www/ucp_app/backend\n"
            "ExecStart=/var/www/ucp_app/backend/venv/bin/gunicorn --workers 3 --bind 127.0.0.1:8000 ucp_backend.wsgi:application\n\n"
            "[Install]\n"
            "WantedBy=multi-user.target\n"
        )
        service_path = "/etc/systemd/system/gunicorn.service"
        with sftp.file(service_path, 'w') as f:
            f.write(gunicorn_service)
        print(f"Created Gunicorn service file at {service_path}")
        
        # Restart and enable Gunicorn daemon
        run_ssh_command(ssh, "systemctl daemon-reload")
        run_ssh_command(ssh, "systemctl start gunicorn")
        run_ssh_command(ssh, "systemctl enable gunicorn")
        run_ssh_command(ssh, "systemctl restart gunicorn")
        
        # Step 7: Compress and upload locally built Flutter Web app to VPS
        print("\n--- Step 7: Uploading locally built Flutter Web application (zipped) ---")
        local_zip_path = os.path.join(LOCAL_PROJECT_ROOT, "web_build.zip")
        zip_dir(LOCAL_WEB_BUILD_DIR, local_zip_path)
        
        # Install unzip on the remote server if not present
        run_ssh_command(ssh, "apt-get install -y unzip")
        
        remote_zip_path = "/tmp/web_build.zip"
        print(f"[SFTP] Uploading {local_zip_path} -> {remote_zip_path}...")
        sftp.put(local_zip_path, remote_zip_path)
        
        remote_web_dir = f"{repo_dir}/frontend/build/web"
        run_ssh_command(ssh, f"rm -rf {remote_web_dir} && mkdir -p {remote_web_dir}")
        print("Extracting zip archive on the remote server...")
        run_ssh_command(ssh, f"unzip -o {remote_zip_path} -d {remote_web_dir}")
        
        # Clean up local and remote zip files
        if os.path.exists(local_zip_path):
            os.remove(local_zip_path)
        run_ssh_command(ssh, f"rm -f {remote_zip_path}")
        print("Flutter Web application uploaded and extracted successfully!")
        
        # Step 8: Configure Nginx site server block
        print("\n--- Step 8: Configuring Nginx server block ---")
        nginx_conf = (
            "server {\n"
            "    listen 80;\n"
            "    server_name ucp.moha85awad.site;\n\n"
            "    location / {\n"
            "        root /var/www/ucp_app/frontend/build/web;\n"
            "        index index.html;\n"
            "        try_files $uri $uri/ /index.html;\n"
            "    }\n\n"
            "    location /static/ {\n"
            "        alias /var/www/ucp_app/backend/staticfiles/;\n"
            "    }\n\n"
            "    location /media/ {\n"
            "        alias /var/www/ucp_app/backend/media/;\n"
            "    }\n\n"
            "    location ~ ^/(api|admin) {\n"
            "        proxy_pass http://127.0.0.1:8000;\n"
            "        proxy_set_header Host $host;\n"
            "        proxy_set_header X-Real-IP $remote_addr;\n"
            "        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;\n"
            "        proxy_set_header X-Forwarded-Proto $scheme;\n"
            "    }\n"
            "}\n"
        )
        nginx_site_path = "/etc/nginx/sites-available/ucp_app"
        with sftp.file(nginx_site_path, 'w') as f:
            f.write(nginx_conf)
        print(f"Created Nginx configuration at {nginx_site_path}")
        
        # Enable nginx config
        run_ssh_command(ssh, "ln -sf /etc/nginx/sites-available/ucp_app /etc/nginx/sites-enabled/")
        run_ssh_command(ssh, "rm -f /etc/nginx/sites-enabled/default")
        run_ssh_command(ssh, "nginx -t")
        run_ssh_command(ssh, "systemctl restart nginx")
        
        # Step 9: Configure free SSL using Certbot
        print("\n--- Step 9: Generating free SSL Certificate using Certbot ---")
        # Run certbot to automatically fetch certificate and configure SSL redirections
        run_ssh_command(
            ssh, 
            "certbot --nginx -d ucp.moha85awad.site --non-interactive --agree-tos -m moha85awad@gmail.com"
        )
        
        # Restart Nginx once more to ensure SSL works beautifully
        run_ssh_command(ssh, "systemctl restart nginx")
        
        print("\n=======================================================")
        print("[SUCCESS] Deployment to Hostinger VPS is fully complete!")
        print("Your application is now globally live at: https://ucp.moha85awad.site")
        print("Django Admin panel is live at: https://ucp.moha85awad.site/admin")
        print("=======================================================")
        
    except Exception as e:
        print(f"\n[ERROR] An error occurred during deployment: {e}")
        import traceback
        traceback.print_exc()
        
    finally:
        sftp.close()
        ssh.close()
        print("\nSSH Session closed.")

if __name__ == '__main__':
    main()
