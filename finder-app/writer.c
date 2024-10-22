/*  writer.c
*   
*   Small application to write a string to a file.
*   All actions will be loggeg in the syslog /var/log/syslog on USER-level and with DEBUG or ERROR priority
*   
*   @param file_to_write - Name of file to write into
*   @param string_to_write - String text to write to file
*
*   @retun 0 on succes or 1 on any error
*/

#include <stdio.h>
#include <syslog.h>

int main(int argc, char* argv[])
{    
    //Connect to syslog
    openlog(NULL, 0, LOG_USER);

    // Chek correct number of arguments
    if (argc != 3){
        printf("Not correct number of arguments supplied. Expected number of arguments: 2.\n");
        printf("Usage: %s <string_to_write> <file_to_write>.\n", argv[0]);
        syslog(LOG_ERR, "Invalid Number of arguments: %d", argc);
        return 1;
    }

    // Variables
    const char* filename = argv[1];
    const char* writestr = argv[2];

    FILE* file = fopen(filename, "w");

    //Check if file exist and writing string
    if (file == NULL){
        printf("File doesn't exist.\n");
        syslog(LOG_ERR, "File: %s does not exists", filename);

        return 1;
    } else {
        printf("File: %s exists.\n",filename);
        syslog(LOG_DEBUG, "Writing %s to %s...",writestr, filename);
        
        //Write to file and check if successfull
        if( fprintf(file, "%s", writestr) < 0){
            printf("Could not write to file %s", filename);
            syslog(LOG_ERR, "Could not write to file %s", filename);

            return 1;    
        }
    }
    // Close connection to syslog and close file
    fclose(file);
    closelog();

    return 0;
}