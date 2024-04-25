from github import Github
import os

# Define your GitHub personal access token
access_token = 'YOUR_PERSONAL_ACCESS_TOKEN'

# Create a GitHub instance using the access token
g = Github(access_token)

# Specify the repository where you want to upload the folder
repo = g.get_repo('username/repository_name')

# Path to the folder you want to upload
folder_path = 'path/to/your/folder'

# Iterate over the files in the folder
for root, dirs, files in os.walk(folder_path):
    for file_name in files:
        # Read the content of each file
        file_path = os.path.join(root, file_name)
        with open(file_path, 'r') as file:
            content = file.read()

        # Specify the file path in the repository
        relative_path = os.path.relpath(file_path, folder_path)
        github_path = os.path.join('Upload-Images', relative_path)  # Assuming 'Upload-Images' is the folder name in GitHub

        # Specify the commit message
        commit_message = f"Added {relative_path} to Upload-Images folder"

        # Create or update the file in the repository
        repo.create_file(github_path, commit_message, content)
