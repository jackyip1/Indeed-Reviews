library(data.table)

salarytable <- fread('salary.csv')

newsalary <- gsub('\\$', '', salarytable$'salary')
newsalary <- gsub(',', '', newsalary)
newsalary <- as.numeric(newsalary)
salarytable$'salary' <- newsalary 
head(salarytable)

# replace all hourly wage with annual salary
salarytable[salarytype == "per hour", salary := salary*37.5*52]

# replace existing "per hour" salary type with "per year"
salarytable[salarytype == "per hour", salarytype := "per year"]

fwrite(salarytable, 'salary.csv')
