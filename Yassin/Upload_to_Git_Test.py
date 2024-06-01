from github import Github
import os

# Define your GitHub personal access token
access_token = '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'

# Create a GitHub instance using the access token
g = Github(access_token)

# Specify the repository where you want to upload the folder
repo = g.get_repo('MaartenH327/Data-Challenge-BAN_Predicting-BSA')

# Path to the folder you want to upload
folder_path = 'Yassin'

# Iterate over the files in the folder
for root, dirs, files in os.walk(folder_path):
    for file_name in files:
        # Read the content of each file
        file_path = os.path.join(root, file_name)
        with open(file_path, 'rb') as file:  # Read file as binary
            content = file.read()

        # Specify the file path in the repository
        relative_path = os.path.relpath(file_path, folder_path)
        github_path = os.path.join('Yassin', relative_path)  # Assuming 'Upload-Images' is the folder name in GitHub

        # Specify the commit message
        commit_message = f"Added {relative_path} to Yassin folder"

        # Check if the file already exists in the repository
        try:
            repo_file = repo.get_contents(github_path)
            # Update the file if it exists
            repo.update_file(repo_file.path, commit_message, content, repo_file.sha)
            print(f"Updated {github_path}")
        except:
            # Create the file if it does not exist
            repo.create_file(github_path, commit_message, content)
            print(f"Created {github_path}")
