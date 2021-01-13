#### Format of HTML code ####
##<div class = "flightPageDataLabel">Aircraft Type</div>
##
##<div class="flightPageData">...</div>
from selenium import webdriver
import csv
import bs4

browser = webdriver.PhantomJS()
##browser = webdriver.Chrome(R"C:\Users\darre\chromedriver_win32\bin")
address = "https://flightaware.com/live/flight/"
aircraftTypes = []
counter = 0

def findAircraftType(tag):
    if tag.string == "Aircraft Type":
        return True
    return False

with open("unique_TailNo.csv", "r", encoding="utf-8") as file:
    lines = file.readlines()
    print(type(lines))
    print(len(lines))
    start = counter
    for tailnum in lines[start:]:
        counter+=1
        print(str(counter) + ": " + tailnum)

        browser.get(address + tailnum)
        html = browser.page_source

        obj = bs4.BeautifulSoup(html, 'html.parser')
        tag = obj.find(findAircraftType)
        nextTag = None
        if tag:
            print("tag: " + tag.string)
            nextTag = tag.next_sibling
            if nextTag:
                nextTag = nextTag.next_sibling
        
        AircraftType = ''
        if nextTag:
            for c in nextTag.children:
                if isinstance(c, bs4.Tag):
                    AircraftType = c.string
                    print("aircraft type: " + AircraftType)
                    break
        aircraftTypes.append(AircraftType)

with open("store_aircraftTypes.csv", "w", encoding="utf-8") as file:
    if len(aircraftTypes) >= 1:
        for at in aircraftTypes:
            file.write(at + ",")
    print("Aircraft Type: " + AircraftType)
