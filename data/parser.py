import dpkt
import csv
import time
import socket
import os
import shutil
import fileinput
import codecs
import requests
import time

#get all files in directory
fileList = []
pcaps = []

requestCap = 150 #for certain APIs
currentRequests = 0

#turns flags into a factor for the dataset
def flagToFactor(flag):
    switcher = {
        0: "Nothing",
        1: "FIN",
        2: "SYN",
        16: "ACK",
        18: "SYNACK",
        24: "ACKPSH",
    }
    
    return switcher.get(flag, "Nothing")

def getIpGeoInfo(address):
    jsondata = requests.get("http://ip-api.com/json/" + address).json()
    
    return jsondata

fileList = [f for f in os.listdir(".") if (os.path.isfile(f))]
print(fileList)

for file in fileList:
    if(file.endswith('.pcap') or file.endswith('.pcapng')):
        pcaps.append(file)
        print("pcap added")
        
print(pcaps)

totalFiles = 1

for pcap in pcaps:
    totalFiles = totalFiles + 1
    f = open(pcap, 'rb')
    
    #check file is actually a pcap file
    if(f.name.endswith("pcapng")):
        pcap = dpkt.pcapng.Reader(f)
        isFile = True
    elif(f.name.endswith("pcap")):
        pcap = dpkt.pcap.Reader(f)
        isFile = True
    else:
        print("Not a pcap file")
        isFile = False
        
    
    if(isFile):    
        http_data = [["type", "sourceIP", "destIP", "bytes", "sourceport", "method", "bodySize", "version", "uri", "uri_size", "agent", "version", "host", "sum", "flags"]]
        
        
        for ts, buf in pcap:
            eth = dpkt.ethernet.Ethernet(buf)
            ip = eth.data
            tcp = ip.data
            
            #print(dir(tcp))
            #print(dir(ip))
            #print(len(buf))
            
            try:
                if(tcp.dport == 80):
                    tsum = tcp.sum
                    
                    flag = tcp.flags
                    
                    flagFactor = flagToFactor(flag)
                    print(flagFactor)
                    
                    #get http object
                    http = dpkt.http.Request(tcp.data)
                    
                    #get parameters
                    
                    method = http.method           
                    body = http.body
                    bodySize = len(body)
                    version = http.version
                    url = http.uri
                    url_size = len(http.uri)
                    
                    #access headers
                    headers = http.headers
                    host = headers.get("host", "")
                    hostLength = len(host)
                    
                    #print(url)
                    agent = headers.get("user-agent", "")
                    
                    #assume agent is tor if no info provided
                    if(agent == ""):
                        agent = "TOR"
                    
                    #Get ip related information
                    
                    sourceIP = socket.inet_ntoa(ip.src)
                    destinationIP = socket.inet_ntoa(ip.dst)
                    
                    #if(currentRequests == requestCap -1):
                    #    print("REQUEST CAP REACHED, WAITING 1 MINUTE...")
                    #    time.sleep(61)
                        
                    #destinationCountry = json.get("country", "")
                    
                    #print(destinationCountry)

                    
                    #get information about the destination
                    byte = len(buf)
                    sourcePort = tcp.sport
                    
                    #store parameters
                    data = ["malicious", sourceIP, destinationIP, byte, sourcePort, method, bodySize, version, url, url_size, agent, version, host, tsum, flagFactor]
                    
                    http_data.append(data)
            except Exception as e:
                print(str(e))
                
                
        f.close()
        
        timestr = time.strftime("%Y%m%d-%H%M%S")
        
        if(http_data is not None):
            
            with open("http_traffic " + str(totalFiles) + timestr + ".csv", "w", newline='') as csvfile:
                writer = csv.writer(csvfile)
                csvname = csvfile.name
                for row in http_data:
                    writer.writerow(row)
                    
                csvfile.close()
                
            if(os.path.isdir("httpdata") == False):
                os.mkdir("httpdata")
        
            shutil.move(csvname, "httpdata/" + csvname)
        
            print("parsed " + csvname + " successfully")
        else:
            print("No HTTP data found")
        
    http_data = []
    
print(totalFiles)

