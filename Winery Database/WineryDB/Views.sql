--View to pull wines and the winery they are available
	create view view3 as
	select wine_id, winery_name, winery_website,winery_city from winery w1
	inner join winery_wine w2 on w1.Winery_ID=w2.Winery_ID

	create view viewfinal as 
	select w.wine_label,v.winery_name,v.winery_website,v.winery_city from view3 v
	inner join wine w on w.Wine_ID=v.Wine_ID 

----To extract customer names and the wines labels they sell with their prices

	create view View1 as
	Select c.customer_name, p.wine_id,p.Bottle_Price,p.Case_Price,p.Glass_Price
	from customer c inner join price_customer p
	on c.Customer_ID=p.Customer_ID


	create view view2 as
	select v.customer_name,w.wine_label,v.bottle_price,v.case_price,v.glass_price
	from View1 v inner join Wine w on v.Wine_ID=w.Wine_ID