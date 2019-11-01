import time, csv, re, os, datetime

""" Log location """
LOG_FOLDER = "log_query/"
BASE_LOG_NAME = "logquery"
LOG_EXT = ".txt"

""""
Output File Size Options:
b, kb, mb, gb, tb, pb
"""
OUT_FILE_SIZE = "GB"

def parse_log(path, infoLog, comp_unit):
    """
        Parses the target log. File size is converted into OUT_FILE_SIZE
    """
    targetInfo = False
    skipped = 0
    with open(path, "r") as file:
        for line in file:
            # Mark the log you want
            if not targetInfo and "LLAP IO Summary" in line:
                targetInfo = True
            # Capture log info. Skip number of lines until reach desired info
            elif targetInfo and skipped < 3:
                skipped += 1
            elif targetInfo and skipped == 3:
                if "----------" in line:
                    break
                else:
                    temp = line.split()
                    temp.remove("INFO")
                    temp.remove(":")
                    # convert unit to bytes
                    for i in range(len(temp)):
                        item = temp[i]
                        num = re.findall(r"[-+]?\d*\.\d+|\d+", item)
                        unit = re.findall("[a-zA-Z]+", item)
                        # clean up data for easy graphing / calculating
                        if len(num) == 1 and len(unit) == 1:
                            temp_unit = unit[0].upper()
                            if temp_unit in comp_unit:
                                temp[i] = float(num[0]) * comp_unit[temp_unit] / comp_unit[OUT_SIZE]
                            elif temp_unit == "S":
                                temp[i] = num[0] # just the num
                            else:
                                pass
                    # make csv pretty
                    tempStr = temp[0] + temp[1]
                    del temp[0]
                    del temp[1]
                    temp.insert(0, tempStr)
                    # append to infoLog
                    infoLog.append(temp)

def write_csv(log_num, infoLog):
    """
        Writes info to a csv file.
    """
    with open(OUT_NAME, "a", newline="") as output_csv:
        writer = csv.writer(output_csv)
        writer.writerow(["QUERY " + str(log_num)])
        for info in infoLog:
            writer.writerow(info)

OUT_SIZE = OUT_FILE_SIZE.upper()
os.environ["TZ"]="US/Pacific"
time_id = datetime.datetime.now().strftime("%m.%d.%Y-%H.%M")
OUT_NAME = "llapio_summary" + time_id + ".csv"
def main():
    """ Range of queries. Counts the files so you don't need to know which benchmark it is """
    START = 1
    END = 0
    for file in os.listdir(LOG_FOLDER):
        if file.startswith(BASE_LOG_NAME) and file.endswith(LOG_EXT):
            END += 1

    # 2^0 2^10, 2^20, 2^30, 2^40, 2^50
    comp_unit = {"B": 1, "KB": 1024, "MB": 1048576, "GB": 1073741824, "TB": 1099511627776, "PB": 1125899906842624}

    # write header
    with open(OUT_NAME, "w", newline="") as output_csv:
        writer = csv.writer(output_csv)
        head = ["VERTICES", "ROWGROUPS", "META_HIT", "META_MISS", "DATA_HIT({0})".format(OUT_SIZE), "DATA_MISS({0})".format(OUT_SIZE), "ALLOCATION({0})".format(OUT_SIZE), "USED({0})".format(OUT_SIZE), "TOTAL_IO(s)"]
        writer.writerow(head)

    # write info for each query
    for i in range(START, END + 1):
        infoLog = list()
        parse_log(LOG_FOLDER + BASE_LOG_NAME + str(i) + LOG_EXT, infoLog, comp_unit)
        write_csv(i, infoLog)

if __name__ == "__main__":
    start = time.time()
    main()
    end = time.time()
    print("Log parsing finished in {0} secs".format(end - start))
