import scrapy
from indeed.items import IndeedSalary

class IndeedSpider(scrapy.Spider):
	name = 'indeed_salary'
	allowed_urls = ['https://www.indeed.com/']
	start_urls = ['https://www.indeed.com/Best-Places-to-Work?y=2016&cc=US&start=',
	'https://www.indeed.com/Best-Places-to-Work?y=2016&cc=US&start=25']

	def verify(self, content):
		if isinstance(content, list):
			if len(content) > 0:
				content = content[0]
				# convert unicode to str
				return content.encode('ascii','ignore')
			else:
				return "NA"
		else:
			# convert unicode to str
			return content.encode('ascii','ignore')

	def parse(self, response):
		# get all employers on page
		employers = response.xpath('//div[@class="cmp-card-content"]/div')
		for employer in employers:
			# get partial and full urls
			parturl = employer.xpath('.//div[2]/div[3]/a/@href').extract_first()
			fullurl = "https://www.indeed.com" + parturl
			# go to fullurl and keep employer rank
			yield scrapy.Request(fullurl, callback = self.parse_employer)

	def parse_employer(self, response):
		# get employer name
		company = response.xpath('//div[@id="cmp-name-and-rating"]/div[1]/text()').extract()
		company = self.verify(company)
		# get popular job categories displayed
		jobcats = response.xpath('//div[@id="cmp-content"]/div[3]/table')
		# get salary for each position in category
		for jobcat in jobcats:
			category = jobcat.xpath('.//thead/tr/th[1]/text()').extract()
			category = self.verify(category)
			position = jobcat.xpath('.//tbody/tr[1]/td[1]/div/div[1]/a/text()').extract()
			position = self.verify(position)
			salary = jobcat.xpath('.//tbody/tr[1]/td[2]/div/span/text()').extract()
			salary = self.verify(salary)
			salarytype = jobcat.xpath('.//tbody/tr[1]/td[2]/div/text()').extract()
			salarytype = self.verify(salarytype)
			# populate category and salary
			item = IndeedSalary()
			item['company'] = company
			item['category'] = category
			item['position'] = position
			item['salary'] = salary
			item['salarytype'] = salarytype
			yield item