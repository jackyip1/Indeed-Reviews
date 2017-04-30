import scrapy 
from indeed.items import IndeedSalary
from scrapy import Selector

class IndeedSpider(scrapy.Spider):
	name = "indeed_salary"
	allowed_domains = ["indeed.com"]
	start_urls = ['https://www.indeed.com/jobs?q=data+scientist']

	
	def start_requests(self):
		urls = ['https://www.indeed.com/jobs?q=data+scientist']
		for url in urls:
			yield scrapy.Request(url = url, callback = self.parse_page)
			
	def parse_page(self, response):
		item = IndeedSalary()
		#items = []
		for divs in response.css('div.row.result').extract():
			if len(Selector(text=divs).css('div.sjcl').extract()) > 0:
				for hrefs in Selector(text=divs).css('div.sjcl').extract():

					#link =  Selector(text=divs).css('a.jobtitle.turnstileLink::attr(title)').extract_first()
					#print link
					#print "=" * 50

					item['link'] = 'https://www.indeed.com' + str(Selector(text=hrefs).css('span.company a::attr(href)').extract())[3:-2]

					yield scrapy.Request(item['link']+'/salaries', callback = self.parse_salary)

				

			if len(Selector(text=divs).css('div.sjcl').extract()) == 0:
				if len(Selector(text=divs).css('h2.jobtitle').extract()) > 0:
					for refs in Selector(text=divs).css('h2.jobtitle').extract():
					#for refs in response.css('h2.jobtitle'):
						item['link'] = 'https://www.indeed.com' + str(Selector(text=divs).css('span.company a::attr(href)').extract())[3:-2]
						yield scrapy.Request(item['link']+'/salaries', callback = self.parse_salary)


				#if response.css('span.company').extract() is not None:	
					
			
		
			##testing if links work
			#with open('log.txt', 'a') as f:  
				#f.write(str(item))
		yield item
			
		next_page = response.css('div.pagination a::attr(href)').extract()[-1]
		#print 'this should be a link', next_page
		if next_page is not None:
			next_page = response.urljoin(next_page)
			yield scrapy.Request(next_page, callback=self.parse_page)


	def parse_salary(self, response):
		item = IndeedSalary()

		body = response.xpath('//*[@id="cmp-content"]/div[3]/table').extract()
		for i in range(len(body)):
			table = response.xpath('//*[@id="cmp-content"]/div[3]/table').extract()[i]
			for j in range(len(Selector(text=table).xpath('//tr'))):
				item['position'] = response.css('div.cmp-sal-title a::text').extract()
				item['salary'] = response.css('div.cmp-sal-summary span::text').extract()
				item['company'] = response.xpath('//*[@id="cmp-name-and-rating"]/h2/text()').extract_first()
		yield item