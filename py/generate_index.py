import os

EXCLUDED_DIRS = {"images", ".git", "__pycache__"}
README_NAME = "README.md"
START_MARK = "## 📚 File Index"

def generate_file_index():
    lines = [START_MARK, ""]
    for dir_name in sorted(os.listdir()):
        if os.path.isdir(dir_name) and dir_name not in EXCLUDED_DIRS:
            lines.append(f"### 📁 {dir_name}/")
            for filename in sorted(os.listdir(dir_name)):
                full_path = os.path.join(dir_name, filename)
                if os.path.isfile(full_path):
                    lines.append(f"- [`{filename}`]({dir_name}/{filename})")
            lines.append("")
    return "\n".join(lines)

def inject_to_readme():
    with open(README_NAME, "r", encoding="utf-8") as f:
        content = f.read()

    before = content.split(START_MARK)[0].rstrip()
    new_index = generate_file_index()

    with open(README_NAME, "w", encoding="utf-8") as f:
        f.write(before + "\n\n" + new_index + "\n")

inject_to_readme()
