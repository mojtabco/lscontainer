# lscontainer Script


About the Script:
The lscontainer script is a command-line utility designed to display various information about Docker containers running on your system. This information includes container status, image details, network settings, volume details, and environment variables.

Installation and Setup: 
Before executing the script, ensure that jq is installed on your system. If jq is not installed, you can install it using the following command:

  $ sudo apt update

  $ sudo apt install jq

Additionally, you need to set executable permissions for the .sh script files. You can do this by running the following command in the directory containing your .sh scripts:

  $ chmod +x *.sh

Using the Script:
To use the script, navigate to the directory containing the lscontainer.sh script and execute it with the following command to display information about the existing containers:

  $ ./lscontainer.sh

For more detailed information or to utilize specific features, you can use the -e parameter (for displaying environment settings) and the -h parameter (for viewing help documentation):

  $ ./lscontainer.sh -e

  $ ./lscontainer.sh -h

Developer: 
This script was developed by Mojtabco. For assistance or suggestions, please contact him or create an issue in the GitHub repository.

For access to the source code and reporting issues, visit the GitHub Repository: https://github.com/mojtabco/lscontainer
