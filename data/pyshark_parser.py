import pyshark
import csv

capture = pyshark.FileCapture("loocipher.pcapng")
csv_export = [["Protocol", "Source IP Address", "Source Port", "Destination IP Address", "Destination Port", "Captured Length"]]

for packet in capture:
    try:
        
        if(packet.highest_layer == "DNS"):
            print(dir(packet.dns))
            
        else:
            
            srcport = packet.tcp.srcport
            destport = packet.tcp.port
            protocol = packet.highest_layer
            destIP = packet.ip.dst
            sourceIP = packet.ip.src
            length = packet.length
            data = [protocol, sourceIP, srcport, destIP, destport, length]
            csv_export.append(data)
            
            print("record added")
            
            if(len(csv_export) == 6573):
                break            
    except Exception as e:
        
        print("ERROR: " + str(e))

with open("traffic.csv", "w") as csvfile:
    
    writer = csv.writer(csvfile)
    
    for row in csv_export:
        print("WRTIING " + row + "TO FILE")
        writer.writerow(row)

csvfile.close()

print("COMPLETE")