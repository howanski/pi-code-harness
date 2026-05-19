#!/bin/bash
useCritic=1
roundNumber=1
exitAfterInitialPlan=1

message_planner="Read SKETCH_PICODE.md file - this file is for your eyes only.
Your mission is to:
- check which tools will be needed that are not currently in the system
- prepare step-by-step list of tasks that needs to be performed to achieve goal (include missing tools installation), use small steps.
- put this list in TODO_PICODE.md file and remove SKETCH_PICODE.md
- commit changes, init repository if needed
If there are missing tools or other prerequisites than need to be fulfilled before development starts * DO NOT CREATE TODO_PICODE.md - CREATE MISSING_REQUIREMENTS.md *
Do not write any code outside TODO_PICODE.md, you are only planning next steps.
Be precise - the next step will be performed by someone else."

message_executor="Pick up work described in TODO_PICODE.md
Do not try to complete entire app, you only need to:
- analyze current application state
- check if TODO_PICODE.md is correct
- progress app development by ONE logical and consistent step (the smaller step, the better)
- when step is done, update TODO_PICODE.md to contain up-to-date list of what have been done and what needs to be done
Do not install anything unless it is absolutely essential.
You can add positions to todo list and rearrange it whenever you see fit, but do not add new features - only performance/quality tasks.
Be precise - the next step will be performed by someone else.
When everything is complete, remove TODO_PICODE.md
Always commit all changes after ending your turn."

message_critic="Read TODO_PICODE.md file
Your goal is to check if planned steps make sense and if done steps are correct.
Update TODO_PICODE.md file if you think planned steps are wrong or tasks marked as done are not done well.
Do not update any other file, only TODO_PICODE.md.
You can add positions to todo list and rearrange it, but do not add new features - only performance/quality tasks.
Remove any manual tests from todo list - QA will be performed independently, during development we only use automated tests.
Be precise - the next step will be performed by someone else."

clear

# autonomous planning mode
countOfSketches=$(find "/home/picode/workdir/" -iname 'SKETCH_PICODE.md' | wc -l)
if [ "$countOfSketches" -ge 1 ]; then
	echo "--------------------"
	echo "AUTOPLANNING STARTED"
	echo "--------------------"
	cd /home/picode/workdir/
	pi --print "$message_planner"
	echo "---------------------"
	echo "AUTOPLANNING FINISHED"
	echo "---------------------"
	if [ "$exitAfterInitialPlan" -ge 1 ]; then
		echo "BREAK AFTER PLANNING - handoff to human"
		exit
	fi

fi

# autonomous coding mode
countOfTodos=$(find "/home/picode/workdir/" -iname 'TODO_PICODE.md' | wc -l)
if [ "$countOfTodos" -ge 1 ]; then
	echo "-------------------"
	echo "AUTOCODING START..."
	echo "-------------------"
	while [ "$countOfTodos" -ge 1 ]; do
		echo "------------------------------"
		echo "AUTOCODING ROUND $roundNumber STARTED "
		echo "------------------------------"
		cd /home/picode/workdir/
		pi --print "$message_executor"
		echo "-------------------------"
		echo "AUTOCODING ROUND $roundNumber FINISHED"
		echo "-------------------------"
		countOfTodos=$(find "/home/picode/workdir/" -iname 'TODO_PICODE.md' | wc -l)
		if [ "$useCritic" -ge 1 ]; then
			echo "------------------------------"
			echo "AUTO CRITIC ROUND $roundNumber STARTED "
			echo "------------------------------"
			cd /home/picode/workdir/
			pi --print "$message_critic"
			echo "-------------------------------"
			echo "AUTO CRITIC ROUND $roundNumber FINISHED"
			echo "-------------------------------"
		fi
		countOfTodos=$(find "/home/picode/workdir/" -iname 'TODO_PICODE.md' | wc -l)
		roundNumber=$((roundNumber + 1))
	done
	echo "AUTOCODING FINISHED, will now exit"
	exit
fi

if [ "$countOfSketches" -ge 1 ]; then
	echo "---------------------------"
	echo " MISSING REQUIRED PACKAGES"
	echo "---------------------------"
	exit
fi


# interactive mode
while true; do
	date
	echo "You can now safely detach (d)"
	sleep 60
done
