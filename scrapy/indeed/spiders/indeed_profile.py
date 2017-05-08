import scrapy
from indeed.items import IndeedProfile

class IndeedSpider(scrapy.Spider):
	name = 'indeed_profile'
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
			# get rank for each employer
			rank = employer.xpath('.//div[@id="cmp-curated"]/div[1]/span/text()').extract()
			# get partial and full urls
			parturl = employer.xpath('.//div[@id="cmp-curated"]/div[1]/a/@href').extract_first()
			fullurl = "https://www.indeed.com" + parturl
			# go to fullurl and keep employer rank
			yield scrapy.Request(fullurl, callback = self.parse_employer,
				meta = {'rank':rank})

	def parse_employer(self, response):
		# populate employer rank
		rank = response.meta['rank']
		rank = self.verify(rank)

		# get employer name
		company = response.xpath('//div[@class="cmp-company-name"]/text()').extract()
		company = self.verify(company)

		# get employer overall score
		overall = response.xpath('//div[@id="cmp-reviews-overall-view"]/div/span[1]/text()').extract() 
		overall = self.verify(overall) 

		# get employer work/life balance sub-score
		worklife = response.xpath('//dl[@id="cmp-reviews-attributes"]/dd/span/text()')[0].extract()
		worklife = self.verify(worklife) 

		# get employer compensation/benefits sub-score
		compensation = response.xpath('//dl[@id="cmp-reviews-attributes"]/dd/span/text()')[1].extract() 
		compensation = self.verify(compensation)

		# get employer job security/advancement sub-score
		security = response.xpath('//dl[@id="cmp-reviews-attributes"]/dd/span/text()')[2].extract() 
		security = self.verify(security)

		# get employer management sub-score
		management = response.xpath('//dl[@id="cmp-reviews-attributes"]/dd/span/text()')[3].extract() 
		management = self.verify(management)

		# get employer culture sub-score
		culture = response.xpath('//dl[@id="cmp-reviews-attributes"]/dd/span/text()')[4].extract() 
		culture = self.verify(culture)

		# get employer industry
		industry = response.xpath('//ul[@class="cmp-plain-list"]/li/a/text()').extract()
		industry = self.verify(industry)

		# get employer review url
		reviewparturl = response.xpath('//div[@id="cmp-menu-container"]/ul/li[2]/a/@href').extract_first()
		reviewfullurl = "https://www.indeed.com" + reviewparturl

		# populate items
		item = IndeedProfile()
		item['rank'] = rank
		item['company'] = company
		item['overall'] = overall
		item['worklife'] = worklife
		item['compensation'] = compensation
		item['security'] = security
		item['management'] = management
		item['culture'] = culture
		item['industry'] = industry

		yield item

