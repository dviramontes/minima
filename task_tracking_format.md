# Task Tracking Flat File Format

## Format Structure
```
YYYYMMDD task1:status,task2:status,task3:status,...
```

## Key
- `date` - Date in YYYYMMDD format
- `task:+` - Task completed today
- `task:-` - Task not completed today
- `,` - Separator between tasks

## Task Codes (1-3 characters)
```
r    = read        (daily reading habit)
v    = vitamins    (take daily vitamins)
rr   = run/jug     (exercise/cardio)
p    = project     (work on main project)
m    = meditate    (meditation session)
w    = water       (drink water goal)
s    = stretch     (stretching routine)
l    = leetcode    (leetcode practice)
j    = journal     (journaling)
e    = email       (inbox zero)
t    = tidy        (clean/organize)
f    = finance     (review finances)
pl   = plan        (daily planning)
rev  = review      (weekly/monthly review)
mtg  = meeting     (attend meetings)
doc  = document    (write documentation)
tst  = test        (testing/QA)
slp  = sleep       (7+ hours sleep)
lrn  = learn       (learning/study)
wrt  = write       (writing practice)
```

## Example Month File
```
20250901 r:+,v:+,rr:+,p:-,m:+
20250902 r:+,v:+,rr:-,p:+,m:+
20250903 r:-,v:+,rr:+,p:+,m:-
20250904 r:+,v:+,rr:+,p:+,m:+,j:+
20250905 r:+,v:-,rr:+,p:-,m:+
20250906 r:+,v:+,rr:-,p:+,m:+,w:+
20250907 r:+,v:+,rr:+,p:-,m:+,pl:+
20250908 r:+,v:+,rr:+,p:+,m:+,c:+
20250909 r:-,v:+,rr:+,p:+,m:-
20250910 r:+,v:+,rr:-,p:+,m:+,e:+
20250911 r:+,v:+,rr:+,p:-,m:+
20250912 r:+,v:-,rr:+,p:+,m:+,t:+
20250913 r:+,v:+,rr:+,p:+,m:-
20250914 r:-,v:+,rr:-,p:-,m:+,f:+
20250915 r:+,v:+,rr:+,p:+,m:+,c:+,j:+
20250916 r:+,v:+,rr:-,p:+,m:+
20250917 r:+,v:-,rr:+,p:+,m:-
20250918 r:+,v:+,rr:+,p:-,m:+,doc:+
20250919 r:-,v:+,rr:+,p:+,m:+
20250920 r:+,v:+,rr:-,p:+,m:+,w:+,e:+
20250921 r:+,v:+,rr:+,p:-,m:+,pl:+,rev:+
20250922 r:+,v:+,rr:+,p:+,m:+
20250923 r:-,v:-,rr:+,p:+,m:-
20250924 r:+,v:+,rr:-,p:-,m:+,mtg:+
20250925 r:+,v:+,rr:+,p:+,m:+,c:+
20250926 r:+,v:+,rr:-,p:+,m:-,tst:+
20250927 r:-,v:+,rr:+,p:+,m:+
20250928 r:-,v:-,rr:+,p:+
20250929 r:+,v:+,rr:+,p:-,m:+,j:+
20250930 r:+,v:+,rr:-,p:+,m:+,f:+,rev:+
```

## File Naming Convention
- Monthly files: `YYYY-MM.txt` (e.g., `2025-09.txt`)
- Yearly archive: `YYYY.txt` (e.g., `2025.txt`)

## Benefits
- Human-readable and easy to edit manually
- Simple to parse with any programming language
- Compact format (one line per day)
- Easy to grep/search for patterns
- Version control friendly
- Quick visual scanning for streaks and patterns

## Parsing Example (pseudocode)
```
for each line in file:
    date, tasks = split_by_first_space(line)
    for task in split_by_comma(tasks):
        name, status = split_by_colon(task)
        record(date, name, status)
```

## Statistics You Can Calculate
- Completion rate per task: count(+) / total_days
- Current streak: consecutive days with +
- Best streak: longest consecutive x period
- Weekly patterns: completion by day of week
- Task correlation: tasks often done together
