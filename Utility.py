import pandas as pd

def sort_and_save(data):
    '''
    Sorts the data based on price
    Save the data to csv file
    '''
    data = sorted(data, key = lambda i: i['Price'])
    df = pd.DataFrame(data)
    df.to_csv('Iphone Details.csv',sep=',',index=False)