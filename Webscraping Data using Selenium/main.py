from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.common.exceptions import NoSuchElementException, TimeoutException, StaleElementReferenceException
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions
from IPython.display import display
import pandas as pd


class Search:
    def __init__(self, keyword, num_pages):
        # a webdriver bridges Selenium to Chrome browsers
        # Add options keep Chrome browser open after program finishes
        # add_experimental_option method is generally intended to be used temporarily
        # until the Selenium project can push a new release that includes a type-safe setter
        # for whatever Chrome driver has added.
        self.chrome_options = webdriver.ChromeOptions()
        # Setting the detach parameter to true will keep the browser open after the process has ended,
        # so long as the quit command is not sent to the driver.
        self.chrome_options.add_experimental_option("detach", True)
        self.driver = webdriver.Chrome(options=self.chrome_options)

        # replace keyword spaces with '-'
        self.keyword = keyword.replace(' ', '-')
        # we will get the data from Lazada
        self.driver.get(f"https://www.lazada.com.ph/tag/{self.keyword}/")

        # pagination starts at index 3
        self.pi = 3
        self.products = []
        self.product_data = {}
        self.title = ""
        self.price = ""
        self.discount = ""
        self.sales = ""
        self.reviews = ""
        self.location = ""
        self.num_pages = num_pages
        # get available number of pages for the searched keyword
        self.page_end = self.driver.find_element(By.XPATH, '//*[@id="root"]/div/div[2]/div[1]/div/div[1]/div[3]/div/ul/li[8]').text

    def check_keyword_pages(self):
        if self.num_pages <= int(self.page_end):
            # parse keyword
            self.parse_keyword()
            # go to next page if num_pages > 1
            # since the site is already opened at page 1, deduct the num_pages by 1
            # then loop the remaining pages
            for _ in range(self.num_pages - 1):
                button = self.driver.find_element(By.XPATH,
                                         f'//*[@id="root"]/div/div[2]/div[1]/div/div[1]/div[3]/div/ul/li[{self.pi}]/a')
                self.driver.execute_script("arguments[0].click();", button)
                self.pi += 1
                # parse keyword
                self.parse_keyword()

            # add dictionary to a dataframe
            df = pd.DataFrame(self.products)
            display(df)
            df.to_csv('sample.csv', index=False)
        else:
            print(f"There are only {self.page_end} pages for this keyword")

        # close browser
        self.driver.quit()

    def parse_keyword(self):
        # refresh page
        self.driver.refresh()
        # get product items by class name
        product_items = self.driver.find_elements(By.CLASS_NAME, "Bm3ON")
        i = 1
        for products in product_items:
            # Make driver wait to avoid stale element reference exceptions.
            # Get Title
            try:
                WebDriverWait(self.driver, 3) \
                    .until(expected_conditions.presence_of_element_located((By.XPATH,
                                                                            f'//*[@id="root"]/div/div[2]/div[1]/div/div[1]/div[2]/div[{i}]/div/div/div[2]/div[2]/a')))
                self.title = products.find_element(By.XPATH, f'//*[@id="root"]/div/div[2]/div[1]/div/div[1]/div[2]/div[{i}]/div/div/div[2]/div[2]/a').text
            except StaleElementReferenceException:
                self.title = ""
            except NoSuchElementException:
                self.title = ""
            except TimeoutException:
                self.title = ""

            # Get Price
            try:
                WebDriverWait(self.driver, 3) \
                    .until(expected_conditions.presence_of_element_located((By.XPATH,
                                                                            f'//*[@id="root"]/div/div[2]/div[1]/div/div[1]/div[2]/div[{i}]/div/div/div[2]/div[3]/span')))
                self.price = products.find_element(By.XPATH, f'//*[@id="root"]/div/div[2]/div[1]/div/div[1]/div[2]/div[{i}]/div/div/div[2]/div[3]/span').text
            except StaleElementReferenceException:
                self.price = ""
            except NoSuchElementException:
                self.price = ""
            except TimeoutException:
                self.price = ""

            # Get Location
            try:
                WebDriverWait(self.driver, 3) \
                    .until(expected_conditions.presence_of_element_located((By.XPATH,
                                                                            f'//*[@id="root"]/div/div[2]/div[1]/div/div[1]/div[2]/div[{i}]/div/div/div[2]/div[5]/span[2]')))
                self.location = products.find_element(By.XPATH,
                                                      f'//*[@id="root"]/div/div[2]/div[1]/div/div[1]/div[2]/div[{i}]/div/div/div[2]/div[5]/span[2]').text
            except StaleElementReferenceException:
                self.location = ""
            except NoSuchElementException:
                self.location = ""
            except TimeoutException:
                self.location = ""

            # Get Discount
            try:
                WebDriverWait(self.driver, 3) \
                    .until(expected_conditions.presence_of_element_located((By.XPATH,
                                                                            f'//*[@id="root"]/div/div[2]/div[1]/div/div[1]/div[2]/div[{i}]/div/div/div[2]/div[4]/span')))
                self.discount = products.find_element(By.XPATH,
                                                   f'//*[@id="root"]/div/div[2]/div[1]/div/div[1]/div[2]/div[{i}]/div/div/div[2]/div[4]/span').text
            except StaleElementReferenceException:
                self.discount = ""
            except NoSuchElementException:
                self.discount = ""
            except TimeoutException:
                self.discount = ""

            # Get Products Sold
            try:
                WebDriverWait(self.driver, 3) \
                    .until(expected_conditions.presence_of_element_located((By.XPATH,
                                                                            f'//*[@id="root"]/div/div[2]/div[1]/div/div[1]/div[2]/div[{i}]/div/div/div[2]/div[5]/span[1]/span[1]')))
                self.sales = products.find_element(By.XPATH, f'//*[@id="root"]/div/div[2]/div[1]/div/div[1]/div[2]/div[{i}]/div/div/div[2]/div[5]/span[1]/span[1]').text
            except StaleElementReferenceException:
                self.sales = ""
            except NoSuchElementException:
                self.sales = ""
            except TimeoutException:
                self.sales = ""

            # Get Number of Reviews
            try:
                WebDriverWait(self.driver, 3) \
                    .until(expected_conditions.presence_of_element_located((By.XPATH,
                                                                            f'//*[@id="root"]/div/div[2]/div[1]/div/div[1]/div[2]/div[{i}]/div/div/div[2]/div[5]/div/span')))
                self.reviews = products.find_element(By.XPATH, f'//*[@id="root"]/div/div[2]/div[1]/div/div[1]/div[2]/div[{i}]/div/div/div[2]/div[5]/div/span').text
            except StaleElementReferenceException:
                self.reviews = ""
            except NoSuchElementException:
                self.reviews = ""
            except TimeoutException:
                self.reviews = ""

            # Add data to the product_data dictionary
            self.product_data = {"Title": self.title,
                                 "Price": self.price,
                                 "Seller Location": self.location,
                                 "Discount": self.discount,
                                 "Products Sold": self.sales,
                                 "Number of Reviews": self.reviews
                                 }

            # Append product_data dictionary to products list
            self.products.append(self.product_data)
            i += 1


if __name__ == '__main__':
    # get data from the first 5 pages of protein powder keyword
    search = Search("protein powder", 5)
    search.check_keyword_pages()
