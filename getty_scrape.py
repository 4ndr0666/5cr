import os
import time
import requests
from selenium import webdriver
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from urllib.parse import urljoin

# Constants
GETTY_IMAGES_URL = "https://www.gettyimages.com/"
TIMEOUT = 30
SCROLL_PAUSE_TIME = 2

def get_image_urls(driver, search_url, num_pages):
    driver.get(search_url)

    # Wait for the images to load
    WebDriverWait(driver, TIMEOUT).until(
        EC.presence_of_element_located((By.CSS_SELECTOR, "img.gallery-asset__thumb"))
    )

    image_urls = []
    
    for _ in range(num_pages):
        # Scroll down to load more images
        last_height = driver.execute_script("return document.body.scrollHeight")
        while True:
            driver.execute_script("window.scrollTo(0, document.body.scrollHeight);")
            time.sleep(SCROLL_PAUSE_TIME)

            new_height = driver.execute_script("return document.body.scrollHeight")
            if new_height == last_height:
                break
            last_height = new_height

        # Get image URLs
        image_elements = driver.find_elements_by_css_selector("img.gallery-asset__thumb")
        image_urls += [img.get_attribute("src") for img in image_elements]

        try:
            next_page_button = driver.find_element_by_css_selector('.search-pagination__button-icon--next')
            if next_page_button:
                next_page_button.click()
                time.sleep(2)
            else:
                break
        except:
            break

    return image_urls

def download_images(person_name, image_urls, output_dir):
    for idx, url in enumerate(image_urls):
        response = requests.get(url)

        if response.status_code == 200:
            with open(os.path.join(output_dir, f'{person_name}_{idx}.jpg'), 'wb') as f:
                f.write(response.content)
        else:
            print(f"Failed to download image {idx}: {url}")

def main():
    person_name = input("Please provide the person's name: ")
    search_url = input('Please provide the page URL: ')
    output_dir = input('Please provide the directory where the data will be saved: ')
    num_pages = int(input('Please provide how many pages you want to be scrapped: '))

    # Check if the output directory exists, if not, create it
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    options = webdriver.ChromeOptions()
    options.add_argument("--headless")
    options.add_argument("--disable-dev-shm-usage")
    options.add_argument("--no-sandbox")

    with webdriver.Chrome(options=options) as driver:
        image_urls = get_image_urls(driver, search_url, num_pages)
        download_images(person_name, image_urls, output_dir)

if __name__ == "__main__":
    main()
