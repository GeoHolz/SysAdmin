import os

EXCLUDED_DIRS = {"images", ".git", "__pycache__", "py", ".vscode"}
README_PATH = os.path.join(os.path.dirname(__file__), "..", "README.md")
START_MARK = "## 📚 File Index"

def generate_file_index(repo_root):
    lines = [START_MARK, ""]

    def walk_directory(current_dir, prefix=""):
        for dir_name in sorted(os.listdir(current_dir)):
            dir_path = os.path.join(current_dir, dir_name)
            if os.path.isdir(dir_path) and dir_name not in EXCLUDED_DIRS:
                lines.append(f"### 📁 {prefix}{dir_name}/")
                # Recherche des fichiers dans le sous-dossier
                for filename in sorted(os.listdir(dir_path)):
                    full_path = os.path.join(dir_path, filename)
                    if os.path.isfile(full_path):
                        lines.append(f"- [`{filename}`]({prefix}{dir_name}/{filename})")
                # Appel récursif pour explorer les sous-dossiers
                walk_directory(dir_path, prefix + dir_name + "/")

    # Démarrer la traversée du répertoire principal
    walk_directory(repo_root)

    return "\n".join(lines)

def inject_to_readme():
    repo_root = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
    new_index = generate_file_index(repo_root)

    with open(README_PATH, "r", encoding="utf-8") as f:
        content = f.read()

    if START_MARK in content:
        before = content.split(START_MARK)[0].rstrip()
    else:
        before = content.rstrip()

    with open(README_PATH, "w", encoding="utf-8") as f:
        f.write(before + "\n\n" + new_index + "\n")

if __name__ == "__main__":
    inject_to_readme()
