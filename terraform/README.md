# DNS (Domain Name System)

- Преобразование : L7 FQDN > L3 IP адрес + L4 порт : маршрутизация запросов приложений
- Преобразование : L3 IP адрес + L4 порт > L7 FQDN : PTR запись : обратный просмотр

## Иерархия серверов

1. Внутренний DNS
2. Публичный DNS
3. Корневой DNS
4. Авторитетный для домена
5. Авторитетный для поддомена

---

 DNS UDP (User Datagram Protocol) : for simple reqs

- faster : no TLS handshake
- res < 512 bytes per package
 DNS TCP (Transmission Control Protocol) : for zone transfer
- res > 512 bytes per package
- zone transfer : AXFR/IXFR
- signed res : DNSSEC

---

feature/init-infra          # базовая инфра
feature/ansible             # плейбуки

---

Bastion : NAT, public IP, SSH
Client : пользовательский хост
bind9 : корневой сервер имен
Unbind
Knot DNS : сервер имен верхнего уровня
PowerDNS : авторитативный сервер
NSD : авторитативный сервер
haproxy : балансировка нагрузка

---

ssh -F ./.auth/ssh_config dns-resolver
