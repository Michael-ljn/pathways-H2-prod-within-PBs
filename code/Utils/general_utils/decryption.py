import xarray as xr
from cryptography.fernet import Fernet
from io import BytesIO, StringIO
import os,csv,copy
import pandas as pd

def get_delimiter(data=None, filepath=None) -> str:
    sniffer = csv.Sniffer()
    if filepath:
        with open(filepath, "r", encoding="utf-8") as stream:
            data = stream.readline()
    delimiter = str(sniffer.sniff(data).delimiter)
    return delimiter

def get_iam_data(
    key: bytes,
    filepath: str,
) -> xr.DataArray:
    """
    Read the IAM result file and return an `xarray` with dimensions:

    * region
    * variable
    * year

    :param key: encryption key, if provided by user
    :param filedir: file path to IAM file
    :param variables: list of variables to extract from IAM file

    :return: a multidimensional array with IAM data

    """

    if key is None:
        if filepath.suffix in [".csv", ".mif"]:
            print(f"Reading {filepath} as csv file")
            with open(filepath, "rb") as file:
                # read the encrypted data
                encrypted_data = file.read()
                # create a temp csv-like file to pass to pandas.read_csv()
                data = StringIO(str(encrypted_data, "latin-1"))

        elif filepath.suffix in [".xls", ".xlsx"]:
            print(f"Reading {filepath} as excel file")
            data = pd.read_excel(filepath)

        else:
            raise ValueError(
                f"Extension {filepath.suffix} is not supported. Please use .csv, .mif, .xls or .xlsx."
            )
    else:
        # Uses an encrypted file
        fernet_obj = Fernet(key)
        with open(filepath, "rb") as file:
            # read the encrypted data
            encrypted_data = file.read()

        # decrypt data
        decrypted_data = fernet_obj.decrypt(encrypted_data)
        data = StringIO(str(decrypted_data, "latin-1"))

    dataframe = pd.read_csv(
            data,
            sep=get_delimiter(data=copy.copy(data).readline()),
            encoding="latin-1",
        )
    return dataframe