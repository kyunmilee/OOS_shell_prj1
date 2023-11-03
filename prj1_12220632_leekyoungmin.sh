#! /bin/bash
first_function() {
	while true
	do
		read -p "Please enter 'movie id'(1~1682) : " id_number
		echo

		if [ $id_number -ge 1 ] && [ $id_number -le 1682 ]
		then
			break
		fi
	done

	awk -F '|' -v id_num="$id_number" '$1 == id_num {print $0}' u.item
	echo
}

second_function() {
	while true
	do
		read -p "Do you want to get the data of 'action' genre movies from 'u.item'?(y/n) : " yes_no 
		echo

		if [ "$yes_no" == "y" ] || [ "$yes_no" == "n" ]
		then
			break
		fi
	done
	if [ "$yes_no" == "y" ]
	then
		awk -F '|' '$7 == 1 {print $1, $2}' u.item | head -10
		echo
	fi
}

third_function() {
	while true
	do
		read -p "Please enter the 'movie id'(1~1682) : " id_number
		echo

		if [ $id_number -ge 1 ] && [ $id_number -le 1682 ]
		then
			break
		fi
	done
	total=$(awk -F'\t' -v id_num="$id_number" '$2 == id_num { sum+=$3 } END { print sum }' u.data)
	count=$(awk -F'\t' -v id_num="$id_number" '$2 == id_num' u.data | wc -l)
	if [ $count == 0 ]
	then
		echo "can't get rating"
		echo
	else
		average=$(echo "$total $count" | awk '{ print $1 / $2 }')
		average_float=$(echo "$average" | awk '{ print int($1 * 1000000 + 0.5) / 1000000 }')
		average_rating=$(echo "$average_float" | awk '{printf "%.5f", $1 }')
		echo "average rating of $id_number: $average_rating"
		echo
	fi

}

fourth_function() {
	while true
	do
		read -p "Do you want to delete the 'IMDb URL' from 'u.item'?(y/n) : " yes_no
		echo

		if [ "$yes_no" == "y" ] || [ "$yes_no" == "n" ]
		then
			break
		fi
	done
	if [ "$yes_no" == y ]
	then
		sed 's/http:[^)]*)//' u.item | head -10
		echo
	fi
}	

fifth_function() {
	while true
	do
		read -p "Do you want to get the data about users from 'u.user'?(y/n) : " yes_no
		echo

		if [ "$yes_no" == "y" ] || [ "$yes_no" == "n" ]
		then
			break
		fi
	done
	if [ "$yes_no" == "y" ]
	then
		awk -F '|' '{ printf("user %s is %s years old %s %s\n", $1, $2, ($3 == "M" ? "male" : "female"), $4) }' u.user | head -10
		echo
	fi
}

sixth_function() {
	while true
	do
		read -p "Do you want to Modify the format of 'release data' in 'u.item'?(y/n) : " yes_no
		echo
		
		if [ "$yes_no" == "y" ] || [ "$yes_no" == "n" ]
		then
			break
		fi
	done

	if [ "$yes_no" == "y" ]
	then
		IFS=$'\n'
		for movie_info in $(cat u.item | tail -10)
		do
			original_date=$(echo $movie_info | awk -F'|' '{print $3}')
			change_date=$(date -d "$original_date" +"%Y%m%d")
			print_date=$(echo "$movie_info" | sed -E "s/([^|]*\|[^|]*\|)[0-9]{2}-[A-Za-z]{3}-[0-9]{4}/\1$change_date/")
			echo "$print_date"
		done
	echo
	fi
}

seventh_function() {
	while true
	do
		read -p "Please enter the 'user id'(1~943) : " user_number
		echo

		if [ $user_number -ge 1 ] && [ $user_number -le 943 ]
		then
			break
		fi
	done
	
	user_movie_id=$(awk -F'\t' -v user_num="$user_number" '$1 == user_num {print $2}' u.data | sort -n | tr '\n' '|' | sed 's/|$//' )
	echo $user_movie_id
	echo

	top10_user_movie_id=$(awk -F'\t' -v user_num="$user_number" '$1 == user_num {print $2}' u.data | sort -n | head -10)
	
	for topten_user_movie_id in $top10_user_movie_id
	do
		movie_title=$(awk -F'|' -v mvid="$topten_user_movie_id" '$1 == mvid {print $2}' u.item)
		echo "$topten_user_movie_id|$movie_title"
	done
	echo
}

eighth_function() {
	while true
	do
		read -p "Do you want to get the average 'rating' of movies rated by users with 'age' between 20 and 29 and 'occupation' as 'programmer'?(y/n) : " yes_no
		echo
		if [ "$yes_no" == "y" ] || [ "$yes_no" == "n" ]
		then
			break
		fi
	done
	if [ "$yes_no" == "y" ]
	then
    		correct_programmer_ids=$(awk -F'|' '$2 > 19 && $2 < 30 && $4 == "programmer" {print $1}' u.user)

    		echo "$correct_programmer_ids" | awk '{ programmer_ids[$0] = 1; }
		END {
			while ((getline < "u.data") > 0) {
				split($0, arr_u_data, "\t");
				user_id = arr_u_data[1];
				movie_id = arr_u_data[2];
				movie_rating = arr_u_data[3];
				if (user_id in programmer_ids) {
                    			total[movie_id] += movie_rating;
                    			count[movie_id]++;
                		}
            		}
			for (movie_id in total) {
				first_average = total[movie_id] / count[movie_id];
				average_float = int(first_average * 1000000 + 0.5) / 1000000;
				printf "%d %.5f\n", movie_id, average_float;
			}
		}
		' | sed 's/0\+$//' | sed 's/\.$//' | sort -n
	echo	
	fi
}

echo "---------------------------------"
echo "User Name: LEEKYOUNGMIN"
echo "Student Number: 12220632"
echo "[ MENU ]"
echo "1. Get the data of the movie identified by a specific 'movie id' from 'u.item'"
echo "2. Get the data of action genre movies from 'u.item'"
echo "3. Get the average 'rating' of the movie identified by specific 'moive id' from 'u.data'"
echo "4.Delete the 'IMDb URL' from 'u.item'"
echo "5. Get the data about users from 'u.user'"
echo "6. Modify the format of 'release date' in 'u.item'"
echo "7. Get the data of moives rated by a specific 'user id' from 'u.data'"
echo "8. Get the average 'rating of moives rated by users with 'age' between 20 and 29 and 'occupation' as 'programmer'"
echo "9. Exit"
echo "---------------------------------"

while true
do
	read -p "Enter your choice [1-9] " number
	echo

	case $number in
		1)
			first_function;;
		2)
			second_function;;
		3)
			third_function;;
		4)
			fourth_function;;
		5)
			fifth_function;;
		6)
			sixth_function;;
		7)
			seventh_function;;
		8)
			eighth_function;;
		9)
			echo "Bye!"
			break;;
	esac
done
