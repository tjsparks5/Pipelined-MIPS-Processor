"""
Tyler Sparks
EEL4713

Description:
MIPS Assembler

To-Do:
"""

# Dictionary to convert hex to 4-bit binary, used by immtobin()
def hextobin(h):
    return {
        '0': "0000",
        '1': "0001",
        '2': "0010",
        '3': "0011",
        '4': "0100",
        '5': "0101",
        '6': "0110",
        '7': "0111",
        '8': "1000",
        '9': "1001",
        'a': "1010",
        'b': "1011",
        'c': "1100",
        'd': "1101",
        'e': "1110",
        'f': "1111",
    }[h]

# Function to convert hex immediate into binary
def immtobin(imm):
    value = ""
    for h in imm:
        value = value + hextobin(h)
    return value

# Dictionary to convert the opcode to 6-bit binary
def optobin(op):
    return {
        "addi": "001000",
        "addiu": "001001",
        "slti": "001010",
        "sltiu": "001011",
        "andi": "001100",
        "ori": "001101",
        "xori": "001110",
        "lui": "001111",
        "beq": "000100",
        "bne": "000101",
        "blez": "000110",
        "bgtz": "000111",
        "bltz": "000001",
        "bgez": "000001",
        "bltzal": "000001",
        "bgezal": "000001",
        "j": "000010",
        "jal": "000011",
        "lb": "100000",
        "lh": "100001",
        "lwl": "100010",
        "lw": "100011",
        "lbu": "100100",
        "lhu": "100101",
        "lwr": "100110",
        "sb": "101000",
        "sh": "101001",
        "swl": "101010",
        "sw": "101011",
        "swr": "101110",
    }.get(op, "000000")

# Dictionary to convert function code to 6-bit binary
def funtobin(op):
    return{
        "add": "100000",
        "addu": "100001",
        "sub": "100010",
        "subu": "100011",
        "mult": "011000",
        "multu": "011001",
        "div": "011010",
        "divu": "011011",
        "mfhi": "010000",
        "mthi": "010001",
        "mflo": "010010",
        "mtlo": "010011",
        "sll": "000000",
        "srl": "000010",
        "sra": "000011",
        "sllv": "000100",
        "srlv": "000110",
        "srav": "000111",
        "slt": "101010",
        "sltu": "101011",
        "and": "100100",
        "or": "100101",
        "xor": "100110",
        "nor": "100111",
        "jr": "001000",
        "jalr": "001001",
    }[op]

# Function to covert REGIMM to 5-bit binary
def regimm(op):
    return{
        "bltz": "00000",
        "bgez": "00001",
        "bltzal": "10000",
        "bgezal": "10001",
    }[op]

# Function to convert the reg number to 5-bit binary
def regtobin(reg):
    return '{0:05b}'.format(int(reg))

# Function to convert the offset to 16-bit binary
def offtobin(off):
    # If the number is negative
    if(int(off) < 0):
        posnum = int(off) *(-1)
        posbin = '{0:016b}'.format(posnum - 1)
        res = ""
        for bit in posbin:
            if(bit == '0'):
                res += '1'
            if(bit == '1'):
                res += '0'
    
    # If the number is positive
    else:
        res = '{0:016b}'.format(int(off))
    return res

###################
## END FUNCTIONS ##
###################

# Taking in the file name
filename = input("Enter the file name: ")

# Opening the file
asmFile = open(filename, 'r')

# Reading the contents of the file
lines = asmFile.readlines()

# Close the assembly file
asmFile.close()

# Open file to write to
machFile = open("demo.mif", 'w')

# Finding the labels
location = 0
skip = []
labels = []
address = []
startAddress = 4194304;
for line in lines:
    for i in line:
        if(i == ":"):
            # Split the line
            split = line.split(":")
            
            # Record the label
            labels.append(split[0])
            
            # Record the label's address
            address.append("{0:016b}".format(location))
            
            # Math to account for label being at same address as instruction
            location -= 1
            
            # Add the label to the list of lines to skip
            skip.append(line)
            
    location += 1
    
# Create a dictionary from the labels and their addresses
lbtbl = dict(zip(labels, address))

machFile.write("WIDTH=32;" + "\n")
machFile.write("DEPTH=256;" + "\n")
machFile.write("ADDRESS_RADIX=HEX;" + "\n")
machFile.write("DATA_RADIX=HEX;" + "\n")
machFile.write("CONTENT BEGIN" + "\n")  # Write the ouput to the file
# Iterating through each line of the file
location = 0
for line in lines: 
    if line not in skip:
        # Removing characters from the instruction
        line = line.replace(",", "")
        line = line.replace("$", "")
        line = line.replace("0x", "")
        line = line.replace("(", " ")
        line = line.replace(")", "")
        
        # Splitting apart the instruction
        split = line.split()
        out = ""
        
        # Add/Sub R-type
        if split[0] in ("add", "addu", "sub", "subu"):
            out = optobin(split[0]) + regtobin(split[2]) + regtobin(split[3]) + regtobin(split[1]) + "00000" + funtobin(split[0]) 
        
        # Add/Sub I-type
        elif split[0] in ("addi", "addiu"):
            out = optobin(split[0]) + regtobin(split[2]) + regtobin(split[1]) + immtobin(split[3])
        
        # Mult/Div
        elif split[0] in ("mult", "multu", "div", "divu"):
            out = optobin(split[0]) + regtobin(split[1]) + regtobin(split[2]) + "0000000000" + funtobin(split[0])
            
        # mfhi or mflo
        elif split[0] in ("mfhi", "mflo"):
            out = optobin(split[0]) + "0000000000" + regtobin(split[1]) + "00000" + funtobin(split[0])
            
        # mthi or mtlo
        elif split[0] in ("mthi", "mtlo"):
            out = optobin(split[0]) + regtobin(split[1]) + "000000000000000" + funtobin(split[0])
            
        # Shift immediates
        elif split[0] in ("sll", "srl", "sra"):
            out = optobin(split[0]) + "00000" + regtobin(split[2]) + regtobin(split[1]) + regtobin(split[3]) + funtobin(split[0])
            
        # Shift values and Comparison R-type
        elif split[0] in ("sllv", "srlv", "srav", "slt", "sltu"):
            out = optobin(split[0]) + regtobin(split[2]) + regtobin(split[3]) + regtobin(split[1]) + "00000" + funtobin(split[0])
            
        # Comparison I-type, Logical I-type
        elif split[0] in ("slti", "sltiu", "andi", "ori", "xori"):
            out = optobin(split[0]) + regtobin(split[2]) + regtobin(split[1]) + immtobin(split[3])
         
        # Logical R-type
        elif split[0] in ("and", "or", "xor", "nor"):
            out = optobin(split[0]) + regtobin(split[2]) + regtobin(split[3]) + regtobin(split[1]) + "00000" + funtobin(split[0])
        
        # Load upper Immediate
        elif(split[0] == "lui"):
            out = optobin(split[0]) + "00000" + regtobin(split[1]) + immtobin(split[2])
        
        # beq and bne
        elif split[0] in ("beq", "bne"):
            out = optobin(split[0]) + regtobin(split[1]) + regtobin(split[2]) + offtobin(int(lbtbl[split[3]], 2) - location - 1)
        
        # blez and bgtz
        elif split[0] in ("blez", "bgtz"):
            out = optobin(split[0]) + regtobin(split[1]) + "00000" + offtobin(int(lbtbl[split[2]], 2) - location - 1)
        
        # bltz, bgez, bltzal, bgezal
        elif split[0] in ("bltz", "bgez", "bltzal", "bgezal"):
            out = optobin(split[0]) + regtobin(split[1]) + regimm(split[0]) + offtobin(int(lbtbl[split[2]], 2) - location - 1)
        
        # Unconditional Jumps
        elif split[0] in ("j", "jal"):
            out = optobin(split[0]) + '{0:026b}'.format(int(lbtbl[split[1]], 2) + startAddress)
            
        # Jump Register
        elif(split[0] == "jr"):
            out = optobin(split[0]) + regtobin(split[1]) + "000000000000000" + funtobin(split[0])
        
        # Jump Register and Link
        elif(split[0] == "jalr"):
            out = optobin(split[0]) + regtobin(split[1]) + "00000" + regtobin(split[2]) + "00000" + funtobin(split[0])
        
        # Loads and Stores
        elif split[0] in ("lb", "lh", "lwl", "lw", "lbu", "lhu", "lwr", "sb", "sh", "swl", "sw", "swr"):
            out = optobin(split[0]) + regtobin(split[3]) + regtobin(split[1]) + offtobin(split[2]) 
        
        out = '{0:03X}'.format(location) + " : " + '{0:08X}'.format(int(out, 2))  # Convert the output to hex
        print(out)
        machFile.write("\t" + out + ";" + "\n")  # Write the ouput to the file
        
        location += 1
        
# Closing the output file
machFile.write("\t" + "[" + '{0:03X}'.format(location) + "..0ff]" + " " + ":" + " " + "00000000" + "\n")
machFile.write("END" + "\n")
machFile.close();
print("Written to demo.mif")