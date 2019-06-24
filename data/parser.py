import dpkt

f = open("loocipher.pcapng", 'rb')
http_data = ["method", "uri", "code", "domain"]
pcap = dpkt.pcapng.Reader(f)

for ts, buf in pcap:
    eth = dpkt.ethernet.Ethernet(buf)
    ip = eth.data
    tcp = ip.data
    try:        
        if(tcp.dport == 80):
            http = dpkt.http.Request(tcp.data)
            print(http.method)
    except Exception as e:
        print("ERROR: " + str(e))
        

f.close()