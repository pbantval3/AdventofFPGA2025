file_path = "input.txt"

try:
    with open(file_path, 'r') as file:
        lines = file.readlines()
except FileNotFoundError:
    print(f"Error {file_path} not found")
except Exception as e:
    print(f"Error: {e}")

pos = 50
count = 0
temp_val = 0
for line in lines:
    num = int(line[1:])
    if line[0] == 'L':
        pos = 100 if pos == 0 else pos
        temp_val = pos-num
    if line[0] == 'R':
        temp_val = pos+num
    while temp_val < 0 or temp_val > 100:
        if temp_val < 0:
            temp_val += 100
            count += 1
        if temp_val > 100:
            temp_val -= 100
            count += 1
    pos = temp_val
    if pos == 0 or pos == 100: 
        count += 1
        pos = 0
print("count")
print(count)
