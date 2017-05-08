import scrapy
from indeed.items import IndeedReview
import requests

class IndeedSpider(scrapy.Spider):
	name = 'indeed_review'
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
			parturl = employer.xpath('.//div[@id="cmp-curated"]/div[1]/a/@href').extract_first()
			fullurl = "https://www.indeed.com" + parturl
			# go to fullurl and keep employer rank
			yield scrapy.Request(fullurl, callback = self.parse_employer)

	def parse_employer(self, response):
		# get employer name
		company = response.xpath('//div[@class="cmp-company-name"]/text()').extract()
		company = self.verify(company)

		# get employer review url
		reviewparturl = response.xpath('//div[@id="cmp-menu-container"]/ul/li[2]/a/@href').extract_first()
		reviewfullurl = "https://www.indeed.com" + reviewparturl

		index = 0
		while index < 10000:
			try:
				reviewfullurl_each = reviewfullurl + '?start=' + str(index)
				yield scrapy.Request(reviewfullurl_each, callback = self.parse_employer_review,
					meta = {'company': company, 'dont_redirect': True})
				index = index + 20
			except:
				pass


	def parse_employer_review(self, response):
		# populate employer profile
		company = response.meta['company']

		# get reviews
		reviews = response.xpath('//div[@class="cmp-review-container"]')
		for review in reviews:
			rating = review.xpath('.//div[1]/div[2]/div[1]/div/span/span/span/@title').extract()
			rating = self.verify(rating)
			header = review.xpath('.//div[1]/div[2]/div[2]/span[1]/text()').extract()
			header = self.verify(header)
			jobtitle = review.xpath('.//div[1]/div[2]/div[4]/span[1]/span/text()').extract()
			jobtitle = self.verify(jobtitle)
			location = review.xpath('.//div[1]/div[2]/div[4]/span[2]/text()').extract()
			location = self.verify(location)		
			date = review.xpath('.//div[1]/div[2]/div[4]/span[3]/text()').extract()
			date = self.verify(date)	
			comment = review.xpath('.//div[1]/div[3]/div/span/text()').extract()
			comment = self.verify(comment)
			pro = review.xpath('.//div[1]/div[3]/div[2]/div[1]/div[2]/text()').extract()
			pro = self.verify(pro)
			con = review.xpath('.//div[1]/div[3]/div[2]/div[2]/div[2]/text()').extract()
			con = self.verify(con)

			# populate items
			item = IndeedReview()
			item['rating'] = rating
			item['company'] = company
			item['header'] = header
			item['jobtitle'] = jobtitle
			item['location'] = location
			item['date'] = date
			item['comment'] = comment
			item['pro'] = pro
			item['con'] = con

			yield item

