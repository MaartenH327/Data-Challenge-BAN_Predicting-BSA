from github import Github
import os

# Replace with your GitHub personal access token
ACCESS_TOKEN = 'your_github_access_token'
# Replace with your repository name in the format 'username/repo'
REPO_NAME = 'username/repo'
# Replace with the path to your .ipynb file
FILE_PATH = 'path/to/your/notebook.ipynb'
# Replace with the path where you want to save the file in the repository
REPO_PATH = 'notebooks/notebook.ipynb'
# Commit message
COMMIT_MESSAGE = 'Add new Jupyter notebook'

def upload_file_to_github(token, repo_name, file_path, repo_path, commit_message):
    g = Github(token)
    repo = g.get_repo(repo_name)

    with open(file_path, 'r') as file:
        content = file.read()

    try:
        # Try to get the file to check if it exists
        contents = repo.get_contents(repo_path)
        # If it exists, update the file
        repo.update_file(contents.path, commit_message, content, contents.sha)
        print(f'File {repo_path} updated in the repository {repo_name}')
    except:
        # If the file does not exist, create it
        repo.create_file(repo_path, commit_message, content)
        print(f'File {repo_path} created in the repository {repo_name}')

# Call the function to upload the file
upload_file_to_github(ACCESS_TOKEN, REPO_NAME, FILE_PATH, REPO_PATH, COMMIT_MESSAGE)
