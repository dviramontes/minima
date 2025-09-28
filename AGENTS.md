Habito, a habit tracking app

### TODO
[ ] create a YYYY-MM.txt file 

### Subgoals
Goals that will allow me to learn enough zig
to create the CLI

[ ] consume positional arguments from CLI 
[ ] create file using zig
[ ] get current system day and print it 

### Questions
- Do I need to use SQLite to keep track of taks completed or should i simply store the tasks in a header such as
```txt
[key]
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

[tasks]
20250927 r:-,v:+,rr:+,p:+,m:+
20250928 r:-,v:-,rr:+,p:+
20250929 r:+,v:+,rr:+,p:-,m:+,j:+
20250930 r:+,v:+,rr:-,p:+,m:+,f:+,rev:+

```
or maybe i can use TOML?
