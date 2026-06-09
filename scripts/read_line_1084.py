import json

path = "/home/mostafa/.gemini/antigravity/brain/86cbf519-2549-4522-b765-c68a59701d94/.system_generated/logs/overview.txt"
with open(path, "r", encoding="utf-8") as f:
    lines = f.readlines()

line = lines[1083] # 0-indexed line 1084 is index 1083
try:
    data = json.loads(line)
    content = data.get("content", "")
    print("Content length:", len(content))
    print(content)
except Exception as e:
    print("Error:", e)
    print("Raw line length:", len(line))
    print(line[:1000])
