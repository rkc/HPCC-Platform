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

s5  := [ [1,2,3], [4,5,6], [1,1+1,4-1] ];
o21 := s5[1][1];

o21;              // Syntax error near ;
s5[1][1];          // Internal error: assert(!"Should never occur - should have been transformed to an OUTPUT()")
output(o21);      // Syntax error near ")" : expected '[', =, <>, <=, <, >=, >
output(s5[1][1]);  // Internal error: assert(!"Should never occur - should have been transformed to an OUTPUT()")
