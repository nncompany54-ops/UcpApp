import socket

ip = '72.62.244.69'
ports = [22, 80, 443, 5678, 2222, 8080, 3306, 5432, 21, 23]

print(f"Scanning ports for {ip}...")
for port in ports:
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.settimeout(2.0)
    result = s.connect_ex((ip, port))
    if result == 0:
        print(f"Port {port} is OPEN!")
    else:
        print(f"Port {port} is closed/filtered (code: {result})")
    s.close()
