def define_env(env):
    @env.macro
    def github_link():
        # L'URL de base de votre dépôt
        base_url = "https://github.com/GeoHolz/SysAdmin/blob/master/docs/"
        # Récupère le chemin relatif du fichier .md actuel 
        page_path = env.page.file.src_path
        # On remplace .md par .ps1 si c'est un script (ou on laisse tel quel)
        # Ici, on adapte pour pointer vers le script associé
        script_path = page_path.replace(".md", ".ps1")
        
        return f"## 📁 File Location\n\n[Script on GitHub]({base_url}{script_path})"