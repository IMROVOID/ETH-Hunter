import os
import shutil
from pathlib import Path

# --- Configuration ---
# List of important files and directories to include in the takeout.
IMPORTANT_PATHS = [
    'lib',
    'windows',
    'assets',
    'pubspec.yaml',
]
TAKEOUT_DIR_NAME = 'takeout'

# --- Blacklist Configuration ---
# Files/directories in this list will be completely ignored (not in guide, not copied).
# Example: 'build', '.git'
COMPLETE_BLACKLIST = [
    # Leave this list empty for now, as requested.
]

# Files with these extensions will be mentioned in the guide but not copied.
# By default, it contains .h, .rc, and .lock files.
FILE_BLACKLIST_EXTENSIONS = [
    '.h',
    '.rc',
    '.lock',
]


def setup_takeout_directory(project_root: Path) -> Path:
    """Creates or cleans the takeout directory."""
    takeout_dir = project_root / TAKEOUT_DIR_NAME
    if takeout_dir.exists():
        print(f"'{TAKEOUT_DIR_NAME}' directory found. Clearing it for a fresh start...")
        shutil.rmtree(takeout_dir)
    takeout_dir.mkdir()
    print(f"Successfully created clean '{TAKEOUT_DIR_NAME}' directory.")
    return takeout_dir


def is_blacklisted(path: Path, blacklist: list) -> bool:
    """Check if a path or any of its parts are in the complete blacklist."""
    return any(part in blacklist for part in path.parts)


def generate_tree_structure(root_path: Path, path_to_scan: Path, prefix: str = "") -> str:
    """Recursively generates a visual tree structure for a given path."""
    structure = ""
    
    # Filter out blacklisted paths before sorting
    items = [
        p for p in path_to_scan.iterdir()
        if not is_blacklisted(p.relative_to(root_path), COMPLETE_BLACKLIST)
    ]
    items.sort(key=lambda p: p.name)
    
    pointers = ["├── "] * (len(items) - 1) + ["└── "]
    
    for pointer, item in zip(pointers, items):
        relative_path = item.relative_to(root_path)
        
        # Add a note for files that are in the file blacklist
        note = ""
        if item.is_file() and item.suffix in FILE_BLACKLIST_EXTENSIONS:
            note = " (in guide, not copied)"
            
        structure += f"{prefix}{pointer}{item.name}{note}\n"
        
        if item.is_dir():
            extension = "│   " if pointer == "├── " else "    "
            structure += generate_tree_structure(root_path, item, prefix + extension)
            
    return structure


def generate_directory_guide(project_root: Path, takeout_dir: Path):
    """Creates the directory_structure_guide.txt file."""
    guide_path = takeout_dir / 'directory_structure_guide.txt'
    print("Generating 'directory_structure_guide.txt'...")
    
    full_structure = "--- Project Structure Guide ---\n\n"
    
    for path_str in IMPORTANT_PATHS:
        path = project_root / path_str
        
        if is_blacklisted(path.relative_to(project_root), COMPLETE_BLACKLIST):
            continue

        if not path.exists():
            full_structure += f"{path_str} (not found)\n\n"
            continue
        
        if path.is_file():
            full_structure += f"{path.name}\n\n"
        elif path.is_dir():
            full_structure += f"{path.name}/\n"
            full_structure += generate_tree_structure(project_root, path, prefix="  ")
            full_structure += "\n"
        
    with open(guide_path, 'w', encoding='utf-8') as f:
        f.write(full_structure)
    print("Guide created successfully.")


def copy_and_rename_files(project_root: Path, takeout_dir: Path):
    """Copies all important files into the takeout directory, converting all to .txt."""
    print("Copying project files...")
    file_count = 0
    
    for path_str in IMPORTANT_PATHS:
        path = project_root / path_str

        # Special case for 'assets': only include in guide, do not copy files.
        if path_str == 'assets':
            print(f"Skipping file copy for '{path_str}' as per configuration.")
            continue

        if not path.exists():
            print(f"Warning: Path '{path_str}' not found, skipping.")
            continue

        if is_blacklisted(path.relative_to(project_root), COMPLETE_BLACKLIST):
            print(f"Skipping blacklisted path: {path_str}")
            continue

        if path.is_file():
            # Handle single files like pubspec.yaml
            new_filename = f"{path.stem}.txt"
            destination_path = takeout_dir / new_filename
            shutil.copy(path, destination_path)
            file_count += 1
            print(f"  - Copied and converted: {path.name} -> {new_filename}")
        
        elif path.is_dir():
            # Handle directories
            for root, _, files in os.walk(path):
                source_dir = Path(root)
                
                if is_blacklisted(source_dir.relative_to(project_root), COMPLETE_BLACKLIST):
                    continue

                for filename in files:
                    source_file = source_dir / filename
                    
                    if source_file.suffix in FILE_BLACKLIST_EXTENSIONS:
                        print(f"  - Skipping blacklisted file: {source_file.relative_to(project_root)}")
                        continue

                    # Create a unique filename to avoid collisions
                    relative_parts = source_file.relative_to(project_root).parts
                    
                    # Example: from "windows/runner/CMakeLists.txt" to "windows_runner_CMakeLists.txt"
                    unique_name = "_".join(relative_parts[:-1] + (source_file.stem,))
                    new_filename = f"{unique_name}.txt"
                        
                    destination_path = takeout_dir / new_filename
                    shutil.copy(source_file, destination_path)
                    file_count += 1
                    print(f"  - Copied and converted: {source_file.relative_to(project_root)} -> {new_filename}")

    print(f"\nSuccessfully copied {file_count} files to '{TAKEOUT_DIR_NAME}'.")


def main():
    """Main function to orchestrate the takeout process."""
    project_root = Path(__file__).parent.resolve()
    print(f"Running takeout script in project root: {project_root}")
    
    try:
        # 1. Create or clean the takeout directory
        takeout_dir = setup_takeout_directory(project_root)
        
        # 2. Create the directory structure guide
        generate_directory_guide(project_root, takeout_dir)
        
        # 3. Copy and process all the files
        copy_and_rename_files(project_root, takeout_dir)
        
        print("\n--- ✅ Takeout Complete! ---")
        print(f"All files are ready in the '{TAKEOUT_DIR_NAME}' folder.")
        print("You can now zip this folder or copy-paste the contents of the files.")
        
    except Exception as e:
        print(f"\n--- ❌ An error occurred ---")
        print(f"Error: {e}")
        print("Please check the console for more details.")

if __name__ == "__main__":
    main()