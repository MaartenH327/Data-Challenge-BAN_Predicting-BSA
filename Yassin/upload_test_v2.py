from github import Github
import os

# Replace with your GitHub personal access token
ACCESS_TOKEN = 'your_github_access_token'
# Replace with your repository name in the format 'username/repo'
REPO_NAME = 'username/repo'
# Replace with the path to your .ipynb file on your local machine
FILE_PATH = 'path/to/your/notebook.ipynb'
# Replace with the path where you want to save the file in the repository
REPO_PATH = 'notebooks/notebook.ipynb'
# Commit message
COMMIT_MESSAGE = 'Add new Jupyter notebook'

def upload_file_to_github(token, repo_name, file_path, repo_path, commit_message):
    try:
        print("Authenticating with GitHub...")
        # Authenticate with GitHub
        g = Github(token)
        user = g.get_user()
        print(f"Authenticated as {user.login}")
        
        print(f"Accessing repository {repo_name}...")
        # Get the repository
        repo = g.get_repo(repo_name)

        print(f"Reading file from {file_path}...")
        # Read the content of the local file
        with open(file_path, 'r') as file:
            content = file.read()

        print(f"Preparing to upload to {repo_path}...")
        try:
            # Check if the file exists in the repository
            contents = repo.get_contents(repo_path)
            print(f"File exists in the repository, updating it...")
            # If it exists, update the file
            repo.update_file(contents.path, commit_message, content, contents.sha)
            print(f'File {repo_path} updated in the repository {repo_name}')
        except Exception as e:
            if '404' in str(e):
                print(f"File does not exist in the repository, creating it...")
                # If the file does not exist, create it
                repo.create_file(repo_path, commit_message, content)
                print(f'File {repo_path} created in the repository {repo_name}')
            else:
                print(f"Error accessing file in repository: {e}")
                raise

    except Exception as e:
        print(f"An error occurred: {e}")

# Call the function to upload the file
upload_file_to_github(ACCESS_TOKEN, REPO_NAME, FILE_PATH, REPO_PATH, COMMIT_MESSAGE)
