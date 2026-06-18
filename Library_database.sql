Create Database Library_db;
use Library_db;

Create table Books_inventory (
book_ID varchar (10) primary key,
Title varchar(50),
Author varchar (100),
Genre varchar (50),
Publisher varchar (100)
);

create table Members (
Member_ID varchar (10) primary key,
Member_name varchar (100),
Member_type  varchar (50),
City varchar (50),
Membership_status varchar (20)
);

Create table Transactions (
Transaction_ID varchar (10) primary key,
Member_ID varchar (10),
Book_ID varchar (10),
Issue_Date date,
Fine_Amount_INR int,

constraint fk_Member foreign key (Member_ID) references Members (Member_ID),
constraint fk_Book foreign key (book_ID) references Books_inventory (book_ID)
);

create table Staff (
Staff_ID varchar (10) primary key,
Staff_Name varchar (100),
Department varchar (50),
Designation varchar(50),
Monthly_Salary_INR int
);

Create table Book_Reviews (
Review_ID varchar (10) primary key,
Book_ID varchar (10),
Member_ID varchar (10),
Rating int,
Review_Comment text,

constraint fk_rev_Book foreign key (book_ID) references Books_inventory (book_ID),
constraint fk_rev_Member foreign key (Member_ID) references Members (Member_ID)
);

select * from books_inventory;
select * from members;
select * from transactions;
select * from staff;
select * from book_reviews;

select
(select count(*) from books_inventory) as Total_Books,
(Select count(*) from members) as Total_Members,
(Select count(*) from transactions) as Total_Transactions,
(Select count(*) from staff) as Total_Staff;

#How many book exist in each genre
select Genre, count(*) as Book_Count
from books_inventory
group by Genre
order by Book_Count desc;

#Active vs Inactive members
select Membership_status, count(*) as Count
from members
group by Membership_status;

#Members by city
select City, count(*) as Member_Count
from members
group by City
order by Member_Count desc;

#Total Fine collected
 select
	sum(Fine_Amount_INR) as Total_Fine,
    count(*) as Transaction_with_fine
from transactions
where Fine_Amount_INR > 0;

#Top 10 most issued books
select
   b.Title,
   b.Author,
   b.Genre,
   count(t.Transaction_ID) as Times_Issued
from books_inventory b
left join transactions t on b.book_ID = t.Book_ID
group by b.book_ID, b.Title, b.Author, b.Genre
order by Times_Issued desc
limit 10;

#Monthly transaction trend
select 
    date_format(Issue_Date, '%Y-%M') as Month,
    count(*) as transactions,
    sum(Fine_Amount_INR) as Fine_Collected
from transactions
group by month
order by month;

#Top rated books
select
    b.Title,
    b.Author,
    round(AVG(r.Rating), 2) as Avg_Rating,
    count(r.Review_ID) as Review_Count
from book_reviews r
join books_inventory b on r.Book_ID = b.book_ID
group by b.book_ID, b.Title, b.Author
having count(r.Review_ID) >= 1
order by Avg_Rating desc
Limit 10;

#Staff salary by department
select
Department,
count(*) as Head_Count,
sum(Monthly_Salary_INR) as Total_Salary,
Round(Avg(Monthly_Salary_INR), 0) as avg_salary
from staff
group by Department
order by Total_Salary desc;

#Members who never borrowed a book
select m.Member_ID, m.Member_name, m.Member_type
from members m
left join transactions t on m.Member_ID = t.Member_ID
where t.Transaction_ID is Null;

#Members with high fine
select
    m.Member_name,
    m.City,
    m.Member_type,
    count(t.Transaction_ID) as Total_Borrows,
    sum(t.Fine_Amount_INR) as Total_fine
from members m
join transactions t on m.Member_ID = t.Member_ID
group by m.Member_ID, m.Member_name, m.Member_type, m.City
order by Total_fine desc
Limit 5;

#Books never reviewed
select b.book_ID, b.Title, b.Author, b.Genre
from books_inventory b
left join book_reviews r on b.book_ID = r.Book_ID
where r. Review_ID is Null;

#Genre popularity: borrows + avg rating
Select
  b.Genre,
  COUNT(DISTINCT t.Transaction_ID) as total_borrows,
  COUNT(DISTINCT r.Review_ID) as total_reviews,
  ROUND(AVG(r.Rating), 2) as avg_rating
from Books_inventory b
Left join Transactions t  ON b.book_ID = t.Book_ID
Left join Book_Reviews r  ON b.book_ID = r.Book_ID
group by b.Genre
order by total_borrows desc;

#Which author has the most books in the library
select Author, count(*) as Books_Count
from books_inventory
group by Author
order by Books_Count  desc
limit 1;

#Which city has members who paid the most total fines?
select
  m.City,
  sum(t.Fine_Amount_INR) as Total_fine,
  count(t.Transaction_ID) as Transactions
from members m
join transactions t on m.Member_ID = t.Member_ID
where t.Fine_Amount_INR > 0
group by m.City
order by Total_fine desc
limit 1;

#Find the highest paid staff member in each department
select
     Department,
     Staff_ID,
     Staff_Name,
     Monthly_Salary_INR
from (
     select 
     Department,
     Staff_ID,
     Staff_Name,
     Monthly_Salary_INR,
     rank() over(
     partition by Department
     order by Monthly_Salary_INR desc
	) as Monthly_Salary_INR_rank 
 from staff
 ) ranked_staff
 where Monthly_Salary_INR_rank = 1;
 
 

	

  
     
     
     



