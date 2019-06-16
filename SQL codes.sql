
/*Question1*/
SELECT T1.title AS Title, quantity2 - quantity1 AS Stock
FROM
(SELECT b.bookTitle AS title, CASE
WHEN transactionTypeID IS NULL THEN 0 ELSE sum(i.quantity) END AS quantity1,
b.bookCode AS code1
FROM Book b
LEFT OUTER JOIN Inventory i
ON b.bookCode = i.bookCode
WHERE i.transactionTypeID = 1 OR transactionTypeID IS NULL
GROUP BY b.bookCode) T1,
(SELECT b.bookTitle AS Title, CASE
WHEN transactionTypeID IS NULL THEN 0 ELSE sum(i.quantity) END AS quantity2,
b.bookCode AS code2
FROM Book b
LEFT OUTER JOIN Inventory i
ON b.bookCode = i.bookCode
WHERE transactionTypeID = 2 OR transactionTypeID IS NULL
GROUP BY b.bookCode) T2
WHERE T1.code1 = T2.code2
/*comment for (P2)Q1: The statement shows title of book and the current stock of its book.
quantity2 represents the number of received books so we subtract quantity1, which is the number of sold books. I used subqueries to distinguish these two quantities. Each of them used LEFT OUTER JOIN because we would want to contain any information for following columns*/

/*Question2*/

SELECT (CASE WHEN roleID = 1 THEN "Manager" ELSE "Non-Manager" END) AS TYPE,
"$"||sum(salary) as SALARY,
round(sum(salary)/(SELECT sum(salary) FROM StaffAssignment)*100,2 )||"%" AS PERCENT
FROM StaffAssignment
GROUP BY TYPE
/*comment for (P2)Q2: The statement shows the type of role and the following salary. The percentage is their salary out of total salaries for staff members. We aligned by TYPE to separate Manager and Non-Manager types.*/

/*Question3*/
SELECT bookGrade AS Grade,
GROUP_CONCAT (" " || b.bookTitle || "(" || STRFTIME('%Y', w.pubDate) || ")") AS Books
FROM Book b ,Writing w ,
(SELECT p.price AS price, p.bookCode AS bookCode
FROM bookprice p, bookprice q
WHERE p.endDate > q.endDate
GROUP BY p.bookCode)AS T1 LEFT JOIN BookGrade g
ON T1.price BETWEEN g.minValue and g.maxValue
WHERE b.bookCode = w.bookCode and T1.bookCode = w.bookCode
GROUP BY bookGrade
/*comment for (P2)Q3: We used subquery to update the latest price for each book. The
table returns categorized books based on grade system. */

/*Question4*/
CREATE VIEW StaffStatus AS
SELECT s.staffFirstName AS Staff,
CASE
WHEN STRFTIME("%s", a.endDate) > STRFTIME("%s", DATETIME ("now", "localtime")) OR
(STRFTIME("%s", a.endDate)is null)
THEN "Active" ELSE "Inactive" END AS Status,
CASE
WHEN STRFTIME("%s", a.endDate) > STRFTIME("%s", DATETIME ("now", "localtime")) OR
(STRFTIME("%s", a.endDate) is null)
THEN CAST ((STRFTIME("%s", DATETIME ("now", "localtime")) - STRFTIME("%s",
a.startDate))/(86400*365.25) AS INT)||" year(s) " ||
CAST (((STRFTIME("%s", DATETIME ("now", "localtime")) - STRFTIME("%s",
a.startDate))/86400)%365.25/30.44 AS INT) || " month(s)"
ELSE CAST((STRFTIME("%s", a.endDate) - STRFTIME("%s", a.startDate))/(86400*365.25) AS
INT)||" year(s)" ||
CAST (((STRFTIME("%s", a.endDate) - STRFTIME("%s", a.startDate))/86400)%365.25/30.44 AS
INT) || " month(s)" END AS Duration
FROM Staff s , StaffAssignment a
WHERE s.staffCode = a.staffCode
ORDER BY Status, Duration DESC;
SELECT * FROM StaffStatus;
/*comment for (P2)Q4: This statement shows the name of staff and how long they have been
working in a company. If their endDate is null or they are still hired, we calculate the
duration between startDate and LocalTime. Otherwise, it is between startDate and
endDate. I used %s which is by seconds units for calculting their duration also used
86400 number to convert seconds to a day, since a day is 86400seconds. If it is about a
year, then we would multiply 365.25 with it. If it is about a month, we would module a
year and then divide by months.*/