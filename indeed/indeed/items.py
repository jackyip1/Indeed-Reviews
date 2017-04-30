# -*- coding: utf-8 -*-

# Define here the models for your scraped items
#
# See documentation in:
# http://doc.scrapy.org/en/latest/topics/items.html

import scrapy


class IndeedProfile(scrapy.Item):
    # define the fields for your item here like:
    # name = scrapy.Field()
    rank = scrapy.Field()
    company = scrapy.Field()
    overall = scrapy.Field()
    worklife = scrapy.Field()
    compensation = scrapy.Field()
    security = scrapy.Field()
    management = scrapy.Field()
    culture = scrapy.Field()
    industry = scrapy.Field()

class IndeedReview(scrapy.Item):
    company = scrapy.Field()
    rating = scrapy.Field()
    header = scrapy.Field()
    jobtitle = scrapy.Field()
    location = scrapy.Field()
    date = scrapy.Field()
    comment = scrapy.Field()
    pro = scrapy.Field()
    con = scrapy.Field()


class IndeedSalary(scrapy.Item):
    company = scrapy.Field()
    category = scrapy.Field()
    position = scrapy.Field()
    salary = scrapy.Field()
    salarytype = scrapy.Field()
