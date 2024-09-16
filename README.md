## Tailscale-Nginx-Proxy-Manager

This little project is a customized Docker container that combines [Tailscale](https://tailscale.com/) and [Nginx Proxy Manager](https://nginxproxymanager.com/) to create a secure, simple way to access services running on your home network from anywhere while connected to a Tailscale tailnet. This solution serves as a drop-in replacement for the original `jc21/nginx-proxy-manager` container.

### Why I Built This

I wanted a way to access various services running on my home network while connected to my Tailscale tailnet, without exposing ports directly on my home router or dealing with the security risks of port forwarding or sharing my IP. By integrating Tailscale with Nginx Proxy Manager, I could expose these services securely, even behind a Carrier-Grade NAT (CGNAT).

Additionally, I aimed to avoid using Docker's `host` networking mode, which would prevent me from accessing other containers on the custom Docker network without exposing those ports on the host machine. This setup allows Nginx Proxy Manager to have direct access to the tailnet while maintaining isolation between containers.

### Key Features

- **Secure Access**: By utilizing Tailscale, you can expose services from behind CGNAT or any restrictive firewall, leveraging the Tailscale mesh VPN.
- **Custom Docker Network**: Avoids using Docker's `host` networking mode, allowing other containers to communicate internally without exposing ports on the host.
- **Persistent Tailscale Session**: The Tailscale session persists across container restarts, eliminating the need to re-authenticate every time the container is restarted.
- **Nginx Stream Functionality**: Use Nginx Proxy Manager's stream feature to expose services like game servers or internal APIs from your home network securely.
- **Compatibility with Nginx Proxy Manager**: Fully compatible with Nginx Proxy Manager's features for easy configuration of proxies, SSL certificates, and more.

### Getting Started

To run the container, use the following `docker-compose.yml` configuration:

```yaml
version: '3.8'
services:
  tsnpm:
    image: 'fizzyfrys/tailscale-nginx-proxy-manager:latest'
    restart: unless-stopped
    hostname: tsnpm # This is the hostname tailscale uses as well
    container_name: tailscale-nginx-proxy-manager
    ports:
      - '80:80'   # Public HTTP Port
      - '443:443' # Public HTTPS Port
      - '81:81'   # Admin Web Port
      - '41741:41741/udp' # Tailscale Port (optional)
    volumes:
      - /containers/nginxproxymanager/data:/data # NginxProxyManager data
      - /containers/nginxproxymanager/letsencrypt:/etc/letsencrypt # NginxProxyManager SSL/TLS certificates
      - /containers/nginxproxymanager/tailscale:/var/lib/tailscale # Persistent storage for Tailscale state
    cap_add:
      - NET_ADMIN
      - SYS_MODULE
    devices:
      - /dev/net/tun
    privileged: true

networks:
  default:
    name: custom-docker-network
    external: true
```

### Initial Setup

1. **Login to Tailscale:**
   To authenticate with Tailscale, run the following command and open the login link:
   ```sh
   docker exec -it tailscale-nginx-proxy-manager tailscale up
   ```

2. **Optionally Enable Auto-Updates in Tailscale:**
   To enable automatic updates for Tailscale:
   ```sh
   docker exec tailscale-nginx-proxy-manager tailscale set --auto-update
   ```

### Important Notes

- **Port 41741**: This port allows the VPS or server running the container to function as if it were a VPN server, even behind CGNAT, without requiring open ports. This is useful for ensuring connections don't rely on Tailscale's relays. I chose port 41741 instead of the usual 41641 to avoid conflicts with Tailscale running on the host system.
  
- **Hostname Issues**: While you can ping Tailscale machines by hostname, I encountered an issue where Nginx Proxy Manager couldn't resolve these hostnames when entering a host in the manager. Using the Tailscale IP addresses worked, and if you know the tailnet name (e.g., `foo.ts.net`), using `machine-name.foo.ts.net` as the hostname also worked, but just the `machinename` alone did not.

### Example Use Case

One of the benefits of this setup is using Nginx Proxy Manager's stream functionality to securely expose my home services through a remote server. For instance, I can expose a Satisfactory game server running at home through my free Oracle Cloud VPS without revealing my home IP address or opening ports on my home network. Here’s how I configured it:

1. **Create Streams host**

   a) Click Add Stream

   b) Incoming Port = `7777`

   c) Forward Port = `7777`

   d) Forward Host = `tailscale-ip-of-home-server`

   e) Enable TCP & UDP Forwarding
   
3. **Added these ports to the docker-compose.yml**
   ```yaml
   ports:
     - '7777:7777/udp' # Satisfactory Server - Uses Nginx stream to expose the server from home
     - '7777:7777/tcp' # Satisfactory Server - Required for the game's status API
   ```


### Final Notes

 I'm not really a programmer so sorry in advance. If anyone has any improvements, suggestions, or ideas, please feel free to contribute!


shameless:

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/I2I013FM5W)
