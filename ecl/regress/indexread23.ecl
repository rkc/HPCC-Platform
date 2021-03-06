/*##############################################################################

    Copyright (C) 2011 HPCC Systems.

    All rights reserved. This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as
    published by the Free Software Foundation, either version 3 of the
    License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
############################################################################## */

#option ('targetClusterType', 'roxie');

namesRecord :=
            RECORD
string20        surname;
string10        forename;
integer2        age := 25;
unsigned8       filepos{virtual(fileposition)};
            END;

d := dataset('x',namesRecord,FLAT);


i1 := index(d, { d } ,'\\home\\person.name_first.key1');
i2 := index(d, { d } ,'\\home\\person.name_first.key2');

boolean whichIndex := false : stored('which');

x1 := i1(keyed(surname='Hawthorn'));
x2 := i2(keyed(surname='Hawthorn'));

i := if(whichIndex, x1, x2);
a2 := limit(i, 2000, keyed,count);
output(a2);
