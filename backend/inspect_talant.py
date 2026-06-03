import paramiko

VPS_IP = '72.62.244.69'
VPS_USER = 'root'
VPS_PASS = 'Moha773836693@'

def run_ssh_commands(commands):
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    
    try:
        print(f"Connecting to VPS {VPS_IP}...")
        ssh.connect(VPS_IP, username=VPS_USER, password=VPS_PASS, timeout=30)
        print("Connected successfully!\n")
    except Exception as e:
        print(f"Failed to connect to VPS: {e}")
        return

    for label, cmd in commands.items():
        print("="*60)
        print(f"INSPECT: {label}")
        print("="*60)
        try:
            stdin, stdout, stderr = ssh.exec_command(cmd)
            out = stdout.read().decode('utf-8', errors='ignore')
            err = stderr.read().decode('utf-8', errors='ignore')
            
            # Safe replacement for Windows console
            out_clean = out.replace('\u25cf', '*').replace('\u2022', '*').strip()
            err_clean = err.replace('\u25cf', '*').replace('\u2022', '*').strip()
            
            if out_clean:
                try:
                    print(out_clean)
                except UnicodeEncodeError:
                    print(out_clean.encode('ascii', errors='replace').decode('ascii'))
            if err_clean:
                try:
                    print("[ERROR/STDERR]")
                    print(err_clean)
                except UnicodeEncodeError:
                    print(err_clean.encode('ascii', errors='replace').decode('ascii'))
            
            status = stdout.channel.recv_exit_status()
            print(f"Exit Status: {status}\n")
        except Exception as ex:
            print(f"Error executing command: {ex}\n")
            
    ssh.close()
    print("SSH Session closed.")

if __name__ == '__main__':
    commands_to_run = {
        "Talant Env File": "cat /root/talant_arabic/.env",
        "Talant Settings Database": "grep -A 15 -rn 'DATABASES =' /root/talant_arabic/osp_project/settings.py || echo 'No database config found'",
        "N8N Inspect Env Variables": "docker inspect n8n | grep -i -A 10 'env'",
        "How is N8N launched (docker inspect)": "docker inspect n8n | grep -i -A 5 -B 5 'HostConfig'"
    }
    run_ssh_commands(commands_to_run)
