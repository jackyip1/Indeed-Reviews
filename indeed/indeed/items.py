# -*- coding: utf-8 -*-

# Define here the models for your scraped items
#
# See documentation in:
# http://doc.scrapy.org/en/latest/topics/items.html

import scrapy


class IndeedItem(scrapy.Item):
    # define the fields for your item here like:
    # name = scrapy.Field()
    rank = scrapy.Field()
    company = scrapy.Field()
    worklife = scrapy.Field()
    compensation = scrapy.Field()
    security = scrapy.Field()
    management = scrapy.Field()
    culture = scrapy.Field()
    industry = scrapy.Field()
    review = scrapy.Field()

