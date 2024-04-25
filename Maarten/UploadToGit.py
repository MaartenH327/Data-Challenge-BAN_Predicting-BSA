from github import Github

# Define your GitHub personal access token
access_token = 'YOUR_PERSONAL_ACCESS_TOKEN'

# Create a GitHub instance using the access token
g = Github(access_token)

# Specify the repository where you want to retrieve content
repo = g.get_repo('username/repository_name')

# Get the file content
file_path = 'path/to/your/file.txt'
file_content = repo.get_contents(file_path).decoded_content.decode()

print(file_content)
