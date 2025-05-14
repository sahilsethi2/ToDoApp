#!/bin/bash  # Shebang - tells the OS to use bash to run this script

FILE="students.txt"  # Filename to store student data
touch $FILE           # Creates the file if it doesn't already exist

# Function to validate that input is not empty
validate_input() {
    if [ -z "$1" ]; then  # Check if argument is empty
        whiptail --msgbox "Input cannot be empty!" 8 40  # Show error message in dialog
        return 1  # Return failure
    fi
    return 0  # Return success
}

# Function to add a student
add_student() {
    # Prompt for Roll Number
    roll=$(whiptail --inputbox "Enter Roll Number:" 8 40 3>&1 1>&2 2>&3)
    validate_input "$roll" || return  # Validate input or exit function

    # Prompt for Name
    name=$(whiptail --inputbox "Enter Name:" 8 40 3>&1 1>&2 2>&3)
    validate_input "$name" || return

    # Prompt for Age
    age=$(whiptail --inputbox "Enter Age:" 8 40 3>&1 1>&2 2>&3)
    validate_input "$age" || return

    # Prompt for Department
    dept=$(whiptail --inputbox "Enter Department:" 8 40 3>&1 1>&2 2>&3)
    validate_input "$dept" || return

    # Prompt for Marks
    marks=$(whiptail --inputbox "Enter Marks (out of 100):" 8 40 3>&1 1>&2 2>&3)
    validate_input "$marks" || return

    # Check if roll number already exists
    if grep -q "^$roll," "$FILE"; then
        whiptail --msgbox "Student with Roll Number $roll already exists!" 8 50
    else
        echo "$roll,$name,$age,$dept,$marks" >> $FILE  # Append student data
        whiptail --msgbox "Student Added Successfully!" 8 40
    fi
}

# Function to display all students
view_students() {
    if [ ! -s "$FILE" ]; then  # Check if file is empty
        whiptail --msgbox "No student records found!" 8 40
        return
    fi

    output="Roll No | Name | Age | Department | Marks | %\n"
    output+="--------------------------------------------------\n"

    while IFS=',' read -r roll name age dept marks; do
        output+="$roll | $name | $age | $dept | $marks | ${marks}%\n"
    done < "$FILE"

    # Show output in a scrollable dialog box
    whiptail --scrolltext --title "All Students" --msgbox "$output" 20 70
}

# Function to search for a student
search_student() {
    # Ask search criteria: Roll Number or Name
    choice=$(whiptail --title "Search Student" --menu "Search by:" 15 50 2 \
    "1" "Roll Number" \
    "2" "Name" 3>&1 1>&2 2>&3)

    if [ "$choice" == "1" ]; then
        roll=$(whiptail --inputbox "Enter Roll Number to search:" 8 40 3>&1 1>&2 2>&3)
        result=$(grep "^$roll," "$FILE")
        if [ -n "$result" ]; then
            IFS=',' read -r roll name age dept marks <<< "$result"
            whiptail --msgbox "Student Found:\nRoll No: $roll\nName: $name\nAge: $age\nDepartment: $dept\nMarks: $marks\nPercentage: $marks%" 15 50
        else
            whiptail --msgbox "Student with Roll Number $roll not found." 8 50
        fi
    else
        name=$(whiptail --inputbox "Enter Name to search:" 8 40 3>&1 1>&2 2>&3)
        results=$(grep -i ",$name," "$FILE")  # Case-insensitive search by name
        if [ -n "$results" ]; then
            output="Roll No | Name | Age | Department | Marks | %\n"
            output+="--------------------------------------------------\n"
            echo "$results" | while IFS=',' read -r roll name age dept marks; do
                output+="$roll | $name | $age | $dept | $marks | ${marks}%\n"
            done
            whiptail --scrolltext --title "Students Found" --msgbox "$output" 20 70
        else
            whiptail --msgbox "No student with name $name found." 8 50
        fi
    fi
}

# Function to delete a student by roll number
delete_student() {
    roll=$(whiptail --inputbox "Enter Roll Number to delete:" 8 40 3>&1 1>&2 2>&3)
    if grep -q "^$roll," "$FILE"; then
        grep -v "^$roll," "$FILE" > temp.txt && mv temp.txt "$FILE"
        whiptail --msgbox "Student Deleted Successfully!" 8 40
    else
        whiptail --msgbox "Student with Roll Number $roll not found." 8 50
    fi
}

# Function to update a student record
update_student() {
    roll=$(whiptail --inputbox "Enter Roll Number to update:" 8 40 3>&1 1>&2 2>&3)
    if grep -q "^$roll," "$FILE"; then
        name=$(whiptail --inputbox "Enter New Name:" 8 40 3>&1 1>&2 2>&3)
        age=$(whiptail --inputbox "Enter New Age:" 8 40 3>&1 1>&2 2>&3)
        dept=$(whiptail --inputbox "Enter New Department:" 8 40 3>&1 1>&2 2>&3)
        marks=$(whiptail --inputbox "Enter New Marks:" 8 40 3>&1 1>&2 2>&3)

        grep -v "^$roll," "$FILE" > temp.txt
        echo "$roll,$name,$age,$dept,$marks" >> temp.txt
        mv temp.txt "$FILE"
        whiptail --msgbox "Student Updated Successfully!" 8 40
    else
        whiptail --msgbox "Student with Roll Number $roll not found." 8 50
    fi
}

# Function to sort students
sort_students() {
    choice=$(whiptail --title "Sort Students" --menu "Sort by:" 15 50 2 \
    "1" "Roll Number" \
    "2" "Name" 3>&1 1>&2 2>&3)

    if [ "$choice" == "1" ]; then
        sorted=$(sort -t',' -k1 -n $FILE | column -t -s',')  # Sort by roll number
    else
        sorted=$(sort -t',' -k2 $FILE | column -t -s',')      # Sort by name
    fi

    whiptail --scrolltext --title "Sorted Students" --msgbox "$sorted" 20 70
}

# Function to backup student file
backup_data() {
    cp $FILE "students_backup.txt"
    whiptail --msgbox "Backup created as students_backup.txt" 8 50
}

# Main loop to show the menu repeatedly
while true; do
    choice=$(whiptail --title "Student Management System" --menu "Choose an option:" 20 60 10 \
    "1" "Add Student" \
    "2" "View All Students" \
    "3" "Search Student" \
    "4" "Delete Student" \
    "5" "Update Student" \
    "6" "Sort Students" \
    "7" "Backup Data" \
    "8" "Exit" 3>&1 1>&2 2>&3)

    # Perform action based on choice
    case $choice in
        1) add_student ;;
        2) view_students ;;
        3) search_student ;;
        4) delete_student ;;
        5) update_student ;;
        6) sort_students ;;
        7) backup_data ;;
        8) whiptail --msgbox "Exiting..." 8 40; break ;;  # Exit the loop
        *) whiptail --msgbox "Invalid choice!" 8 40 ;;    # Handle unknown input
    esac
done
