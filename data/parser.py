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

#delete all files in httpdata, if any.

#get all files in directory
fileList = []

requestCap = 150 #for certain APIs
currentRequests = 0

mypath = os.getcwd()

print(mypath)

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

def ParsePcapsHTTP(fileList, directory, label):
    path = ""
    totalFiles = 0
    
    for file in fileList:
        if(file.endswith('.pcap') or file.endswith('.pcapng')):
            path = str(mypath + directory + file)
            print("pcap added")
            print(path)
            
            totalFiles = totalFiles + 1
            f = open(path, 'rb')
            
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
                http_data = [["type", "sourceIP", "destIP", "bytes", "sourceport", "method", "bodySize", "version", "uri", "fileType", "uri_size", "agent", "version", "host", "hostLength", "onion", "comDomain", "sum", "flags", "tcpwin", "tcpack"]]
                
                
                for ts, buf in pcap:
                    
                    
                    #print(dir(tcp))s
                    #print(len(buf))
                    try:
                        eth = dpkt.ethernet.Ethernet(buf)
                        ip = eth.data
                        tcp = ip.data
                        
                        #print(dir(tcp))
                        
                        if(tcp.dport == 80):
                            
                            tsum = tcp.sum
                            tcpwin = tcp.win
                            flag = tcp.flags
                            ack = tcp.ack
                            seq = tcp.seq
                            
                            #get http object
                            if(dpkt.http.Request(tcp.data)):
                                http = dpkt.http.Request(tcp.data)
                                request = True
                                
                            else:
                                http = dpkt.http.Response(tcp.data)
                                request = False
                                
                            
                            flagFactor = flagToFactor(flag)
                            #print(flagFactor)                    
                            
                            #get parameters
                            
                            method = http.method           
                            body = http.body
                            bodySize = len(body)
                            version = http.version
                            url = http.uri
                            fileurl = url.lower()
                            
                            #check if a file is being requested
                            if(fileurl.endswith(".exe")):
                                fileType = "Executable"
                                
                            elif(fileurl.endswith(".zip") or fileurl.endswith(".gz") or fileurl.endswith(".tar") or fileurl.endswith(".gzip") or fileurl.endswith(".rar")):
                                fileType = "archive"
                                
                            elif(fileurl.endswith(".png") or fileurl.endswith(".jpg") or fileurl.endswith(".jpeg") or fileurl.endswith(".gif") or fileurl.endswith(".svg")):
                                fileType = "image"
                                
                            elif(fileurl.endswith(".js")):
                                fileType = "JavaScript"
                                
                            elif(fileurl.endswith(".css")):
                                fileType = "StyleSheet"
                                
                            elif(fileurl.endswith(".ico")):
                                fileType = "icon"
                            
                            elif(fileurl.endswith(".crx")):
                                fileType = "Chrome Extension"
                            
                            elif(fileurl.endswith(".crl") or fileurl.endswith(".cer") or fileurl.endswith(".crt") or fileurl.endswith(".pem") or fileurl.endswith(".cab")):
                                fileType = "Certificate revocation"
                            
                            elif(method == "POST"):
                                fileType = "POST request"
                            
                            elif(fileurl.endswith(".txt")):
                                fileType = "text file"
                            
                            elif(fileurl.endswith(".woff2")):
                                fileType = "font file"
                            
                            elif(fileurl.endswith(".mp3") or fileurl.endswith(".ogg")):
                                fileType = "audio"
                            
                            elif(fileurl.endswith(".mp4")):
                                fileType = "video"
                            
                            elif(fileurl == "/"):
                                fileType = "host site"
                            
                            elif(fileurl.endswith(".php")):
                                fileType = "PHP backend"
                            
                            elif(fileurl.endswith(".aspx") or fileurl.endswith(".asp")):
                                fileType = "ASP page"
                            
                            elif(file.url.endswith(".cgi")):
                                fileType = "common gateway interface"
                            else:
                                fileType = "other"
                            
                                
                            url_size = len(http.uri)
                            
                            #access headers
                            headers = http.headers
                            host = headers.get("host", "")
                            
                            if(host.endswith(".onion") or host.endswith(".onion.gz") or host.endswith(".onion.to") or host.endswith(".onion.pet") or host.endswith(".onion.sh")):
                                Onionland = True
                            else:
                                Onionland = False
                                
                            #also check if it's a .com domain or not. If it is, mark it as such.
                            
                            if(host.endswith(".com") or host.endswith(".co.uk")):
                                comDomain = True
                            else:
                                comDomain = False
                                
                            hostLength = len(host)
                            
                            #print(url)
                            agent = headers.get("user-agent", "")
                            
                            #assume agent is tor if no info provided
                            if(agent == ""):
                                agent = "Hidden"
                            
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
                            
                            #store parameters and append them to the data
                            data = [label, sourceIP, destinationIP, byte, sourcePort, method, bodySize, version, url, fileType, url_size, agent, version, host, hostLength, Onionland, comDomain, tsum, flagFactor, tcpwin, ack]
                            
                            http_data.append(data)
                            
                    except Exception as e:
                        print(str(e))
                        
                        
                f.close()
                
                timestr = time.strftime("%Y%m%d-%H%M%S")
                
                if(len(http_data) > 0):
                    
                    with open(label + " http_traffic " + str(totalFiles) + timestr + ".csv", "w", newline='') as csvfile:
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
                    print("No HTTP request traffic found")
                
            http_data = []
            
    print(str(totalFiles) + " files parsed")    
    

fileListMal = [f for f in os.listdir(mypath + "\\pcaps_mal") if os.path.isfile(os.path.join(mypath + "\\pcaps_mal", f))]

fileListBenign = [f for f in os.listdir(mypath + "\\pcaps_benign") if os.path.isfile(os.path.join(mypath + "\\pcaps_benign", f))]
print(fileListMal)

#parse each one
ParsePcapsHTTP(fileListMal, "\\pcaps_mal\\", "Malicious")
ParsePcapsHTTP(fileListBenign, "\\pcaps_benign\\", "Benign")