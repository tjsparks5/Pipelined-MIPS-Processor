"""
Tyler Sparks
EEL4713

Description:
MIPS Disassembler

To-Do:
"""

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

def htob(hin):
    binCode = ""
    for h in hin:
        binCode += hextobin(h.lower())
        
    return binCode

# Dictionary to convert the opcode to 6-bit binary
def bintoop(binary):
    return {
        "001000" : "addi",
        "001001" : "addiu",
        "001010" : "slti",
        "001011" : "sltiu",
        "001100" : "andi",
        "001101" : "ori",
        "001110" : "xori",
        "001111" : "lui",
        "000100" : "beq",
        "000101" : "bne",
        "000110" : "blez",
        "000111" : "bgtz",
        "000001" : "bltz",
        "000001" : "bgez",
        "000001" : "bltzal",
        "000001" : "bgezal",
        "000010" : "j",
        "000011" : "jal",
        "100000" : "lb",
        "100001" : "lh",
        "100010" : "lwl",
        "100011" : "lw",
        "100100" : "lbu",
        "100101" : "lhu",
        "100110" : "lwr",
        "101000" : "sb",
        "101001" : "sh",
        "101010" : "swl",
        "101011" : "sw",
        "101110" : "swr",
    }.get(binary, "000000")

# Dictionary to convert function code to 6-bit binary
def bintofun(binary):
    return{
        "100000" : "add",
        "100001" : "addu",
        "100010" : "sub",
        "100011" : "subu",
        "011000" : "mult",
        "011001" : "multu",
        "011010" : "div",
        "011011" : "divu",
        "010000" : "mfhi",
        "010001" : "mthi",
        "010010" : "mflo",
        "010011" : "mtlo",
        "000000" : "sll",
        "000010" : "srl",
        "000011" : "sra",
        "000100" : "sllv",
        "000110" : "srlv",
        "000111" : "srav",
        "101010" : "slt",
        "101011" : "sltu",
        "100100" : "and",
        "100101" : "or",
        "100110" : "xor",
        "100111" : "nor",
        "001000" : "jr",
        "001001" : "jalr",
    }[binary]

def regimm(binary):
    return{
        "00000" : "bltz",
        "00001" : "bgez",
        "10000" : "bltzal",
        "10001" : "bgezal",
    }[binary]
    
def bintoreg(binary):
    return str(int(binary, 2))

def immtohex(imm):
    return "{0:04X}".format(int(imm, 2))

# Taking in the file name
filename = input("Enter the file name: ")

# Opening the file
machFile = open(filename, 'r')

# Reading the contents of the file
lines = machFile.readlines()

# Close the assembly file
machFile.close()

# Open file to write to
asmFile = open("demo.txt", 'w')

# Skip the text at the top of the .mif file
i = 0
while "BEGIN" not in lines[i]:
    i = i+1
lines = lines[i+1:]


for line in lines:
    # Remove unwanted characters
    line = line.replace(":", "")
    line = line.replace(";", "")
    
    # Split apart the line
    split = line.split()
    
    # Convert hex machine code to binary
    binMach = htob(split[1])
    
    out = ""
    
    if(split[0][0] == "[" or split[0] == "END"):
        break
    
    # R-type
    elif(binMach[0:6] == "000000"):
        out += bintofun(binMach[26:32])
        
        # Add/Sub R-type
        if out in ("add", "addu", "sub", "subu", "sllv", "srlv", "srav", "slt", "sltu", "and", "or", "xor", "nor"):
            out += " $" + bintoreg(binMach[16:21]) + ", $" + bintoreg(binMach[6:11]) + ", $" + bintoreg(binMach[11:16]) 
    
        # Mult/Div
        elif out in ("mult", "multu", "div", "divu"):
            out += " $" + bintoreg(binMach[6:11]) + ", $" + bintoreg(binMach[11:16])
            
        # mfhi or mflo
        elif out in ("mfhi", "mflo"):
            out += " $" + bintoreg(binMach[15:20])
            
        # mthi or mtlo
        elif out in ("mthi", "mtlo"):
            out += " $" + bintoreg(binMach[6:11])
            
         # Shift immediates
        elif out in ("sll", "srl", "sra"):
            out +=  " $" + bintoreg(binMach[16:21]) + ", $" + bintoreg(binMach[11:16]) + ", " + bintoreg(binMach[21:26])
            
        # Jump Register
        elif(out == "jr"):
            out += " $" + bintoreg(binMach[6:11])
        
        # Jump Register and Link
        elif(out == "jalr"):
            out += " $" + bintoreg(binMach[6:11]) + ", $" + bintoreg(binMach[15:20])
            
    elif(binMach[0:6] == "000001"):
        out += regimm(binMach[11:16]) + " $" + bintoreg(binMach[6:11]) + ", " + bintoreg(binMach[16:32])
    else:
        out += bintoop(binMach[0:6])
        
        # Add/Sub, Comparison, Logical I-type
        if out in ("addi", "addiu", "slti", "sltiu", "andi", "ori", "xori"):
            out += " $" + bintoreg(binMach[11:16]) + ", $" + bintoreg(binMach[6:11]) + ", 0x" + immtohex(binMach[16:32])
        
        # Load upper Immediate
        elif(out == "lui"):
            out += " $" + bintoreg(binMach[11:16]) + ", 0x" + immtohex(binMach[16:32])
        
         # beq and bne
        elif out in ("beq", "bne"):
            out += " $" + bintoreg(binMach[6:11]) + ", $" + bintoreg(binMach[11:16]) + ", 0x" + immtohex(binMach[16:32])
        
        # blez and bgtz
        elif out in ("blez", "bgtz"):
            out += " $" + bintoreg(binMach[6:11]) + ", 0x" + immtohex(binMach[16:32])
        
        # Unconditional Jumps
        elif out in ("j", "jal"):
            out += ", 0x" + immtohex(binMach[6:32])
        
        # Loads and Stores
        elif out in ("lb", "lh", "lwl", "lw", "lbu", "lhu", "lwr", "sb", "sh", "swl", "sw", "swr"):
            out += " $" + bintoreg(binMach[11:16]) + ", 0x" + immtohex(binMach[16:32]) + "($" + bintoreg(binMach[6:11]) + ")"
    
    out = out.lower()
    print(out)
    asmFile.write(out + "\n")  # Write the ouput to the file

asmFile.close()
print("Written to demo.txt")