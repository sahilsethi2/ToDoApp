#!/bin/bash

FILE="students.txt"
touch $FILE

validate_input() {
    if [ -z "$1" ]; then
        whiptail --msgbox "Input cannot be empty!" 8 40
        return 1
    fi
    return 0
}

add_student() {
    roll=$(whiptail --inputbox "Enter Roll Number:" 8 40 3>&1 1>&2 2>&3)
    validate_input "$roll" || return

    name=$(whiptail --inputbox "Enter Name:" 8 40 3>&1 1>&2 2>&3)
    validate_input "$name" || return

    age=$(whiptail --inputbox "Enter Age:" 8 40 3>&1 1>&2 2>&3)
    validate_input "$age" || return

    dept=$(whiptail --inputbox "Enter Department:" 8 40 3>&1 1>&2 2>&3)
    validate_input "$dept" || return

    marks=$(whiptail --inputbox "Enter Marks (out of 100):" 8 40 3>&1 1>&2 2>&3)
    validate_input "$marks" || return

    if grep -q "^$roll," "$FILE"; then
        whiptail --msgbox "Student with Roll Number $roll already exists!" 8 50
    else
        echo "$roll,$name,$age,$dept,$marks" >> $FILE
        whiptail --msgbox "Student Added Successfully!" 8 40
    fi
}

view_students() {
    if [ ! -s "$FILE" ]; then
        whiptail --msgbox "No student records found!" 8 40
        return
    fi

    output="Roll No | Name | Age | Department | Marks | %\n"
    output+="--------------------------------------------------\n"
    while IFS=',' read -r roll name age dept marks; do
        output+="$roll | $name | $age | $dept | $marks | ${marks}%\n"
    done < "$FILE"

    whiptail --scrolltext --title "All Students" --msgbox "$output" 20 70
}

search_student() {
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
        results=$(grep -i ",$name," "$FILE")
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

delete_student() {
    roll=$(whiptail --inputbox "Enter Roll Number to delete:" 8 40 3>&1 1>&2 2>&3)
    if grep -q "^$roll," "$FILE"; then
        grep -v "^$roll," "$FILE" > temp.txt && mv temp.txt "$FILE"
        whiptail --msgbox "Student Deleted Successfully!" 8 40
    else
        whiptail --msgbox "Student with Roll Number $roll not found." 8 50
    fi
}

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

sort_students() {
    choice=$(whiptail --title "Sort Students" --menu "Sort by:" 15 50 2 \
    "1" "Roll Number" \
    "2" "Name" 3>&1 1>&2 2>&3)

    if [ "$choice" == "1" ]; then
        sorted=$(sort -t',' -k1 -n $FILE | column -t -s',')
    else
        sorted=$(sort -t',' -k2 $FILE | column -t -s',')
    fi

    whiptail --scrolltext --title "Sorted Students" --msgbox "$sorted" 20 70
}

backup_data() {
    cp $FILE "students_backup.txt"
    whiptail --msgbox "Backup created as students_backup.txt" 8 50
}

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

    case $choice in
        1) add_student ;;
        2) view_students ;;
        3) search_student ;;
        4) delete_student ;;
        5) update_student ;;
        6) sort_students ;;
        7) backup_data ;;
        8) whiptail --msgbox "Exiting..." 8 40; break ;;
        *) whiptail --msgbox "Invalid choice!" 8 40 ;;
    esac
done
