import csv
import datetime
import sys, os

pathname = os.path.dirname(sys.argv[0])
abspath=os.path.abspath(pathname)

regioni = ['Piemonte', 'Valle Aosta', 'Lombardia', 'PA Bolzano', 'PA Trento', 'Veneto', 'Friuli', 'Liguria', 'Emilia', 'Toscana',
           'Umbria', 'Marche', 'Lazio', 'Abruzzo', 'Molise', 'Campania', 'Puglia', 'Basilicata', 'Calabria', 'Sicilia', 'Sardegna']

classi_casi = ['1-10', '11-50', '51-100',
               '101-200', '201-500', '501-1000', '1000+']

classi_inc = ['0.01-1', '1.01-5', '5.01-10',
              '10.01-15', '15.01-20', '20.01-40', '40+']

first_day = "20-02-20"
date_start = datetime.datetime.strptime(first_day, "%y-%m-%d")

today=datetime.datetime.now().strftime("%Y-%m-%d")
path=abspath+'/processing/'
f_i_name=path+today+'_incidenzaInizio.csv'
f_c_name=path+today+'_numeroCasiInizio.csv'

f_i = open(f_i_name, 'w')
f_i.write('data,regione,classe_incidenza\n')

with open(abspath+'/processing/raw_incidenzaInizio.csv') as csv_file:
    csv_reader = csv.reader(csv_file, delimiter=',')
    line_count = 0
    for row in csv_reader:
        if line_count == 0:
            print(f'Intestazione {", ".join(row)}')
            line_count += 1
        elif row[0] == '1' and int(row[4]) < 7:
            day = (int(row[2])-1582113600)/86400
            id_regione = int((float(row[3])-0.5))
            my_classe = int(row[4])
            my_date = date_start + datetime.timedelta(days=day)
            print(
                f'\t{my_date.day}/{my_date.month} \t {regioni[id_regione]} \t {classi_inc[my_classe]}')
            f_i.write('{:%y-%m-%d}'.format(my_date)+',' +
                     regioni[id_regione]+','+classi_inc[my_classe]+'\n')
            line_count += 1
    print(f'Elaborate {line_count} righe.')


f_i.close()

f_c = open(f_c_name, 'w')
f_c.write('data,regione,classe_numero_casi\n')

with open(abspath+'/processing/raw_numeroCasiInizio.csv') as csv_file:
    csv_reader = csv.reader(csv_file, delimiter=',')
    line_count = 0
    for row in csv_reader:
        if line_count == 0:
            print(f'Intestazione {", ".join(row)}')
            line_count += 1
        elif row[0] == '1' and int(row[4]) < 7:
            day = (int(row[2])-1582113600)/86400
            id_regione = int((float(row[3])-0.5))
            my_classe = int(row[4])
            my_date = date_start + datetime.timedelta(days=day)
            print(
                f'\t{my_date.day}/{my_date.month} \t {regioni[id_regione]} \t {classi_casi[my_classe]}')
            f_c.write('{:%y-%m-%d}'.format(my_date)+',' +
                     regioni[id_regione]+','+classi_casi[my_classe]+'\n')
            line_count += 1
    print(f'Elaborate {line_count} righe.')


f_c.close()

print(f_i_name)
print(f_c_name)


