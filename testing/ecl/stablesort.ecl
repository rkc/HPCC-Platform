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

ds := DATASET([{17, 1}, {20, 1}, {6, 1}, {4, 1}, {19, 1}, {17, 2}, {13, 1}, {19, 2}, {11, 1}, {4, 2}, {12, 1}, {19, 3}, {13, 2}, {8, 1}, {8, 2}, {3, 1}, {2, 1}, {13, 3}, {3, 2}, {9, 1}, {2, 2}, {5, 1}, {17, 3}, {4, 3}, {14, 1}, {6, 2}, {17, 4}, {19, 4}, {3, 3}, {4, 4}, {13, 4}, {9, 2}, {12, 2}, {17, 5}, {15, 1}, {16, 1}, {5, 2}, {20, 2}, {3, 4}, {13, 5}, {17, 6}, {10, 1}, {6, 3}, {18, 1}, {10, 2}, {19, 5}, {1, 1}, {14, 2}, {6, 4}, {8, 3}, {12, 3}, {15, 2}, {9, 3}, {7, 1}, {7, 2}, {8, 4}, {2, 3}, {4, 5}, {17, 7}, {12, 4}, {2, 4}, {18, 2}, {5, 3}, {7, 3}, {12, 5}, {13, 6}, {7, 4}, {10, 3}, {14, 3}, {18, 3}, {18, 4}, {11, 2}, {14, 4}, {2, 5}, {16, 2}, {17, 8}, {17, 9}, {18, 5}, {1, 2}, {17, 10}, {2, 6}, {10, 4}, {20, 3}, {16, 3}, {20, 4}, {8, 5}, {5, 4}, {18, 6}, {1, 3}, {18, 7}, {15, 3}, {18, 8}, {18, 9}, {7, 5}, {6, 5}, {19, 6}, {3, 5}, {20, 5}, {2, 7}, {12, 6}, {4, 6}, {11, 3}, {4, 7}, {9, 4}, {20, 6}, {7, 6}, {16, 4}, {11, 4}, {1, 4}, {15, 4}, {4, 8}, {18, 10}, {13, 7}, {6, 6}, {19, 7}, {12, 7}, {8, 6}, {1, 5}, {5, 5}, {3, 6}, {1, 6}, {9, 5}, {10, 5}, {19, 8}, {8, 7}, {7, 7}, {6, 7}, {20, 7}, {10, 6}, {4, 9}, {20, 8}, {3, 7}, {9, 6}, {14, 5}, {19, 9}, {19, 10}, {2, 8}, {4, 10}, {5, 6}, {11, 5}, {1, 7}, {5, 7}, {20, 9}, {5, 8}, {3, 8}, {8, 8}, {1, 8}, {5, 9}, {10, 7}, {1, 9}, {10, 8}, {9, 7}, {16, 5}, {8, 9}, {12, 8}, {11, 6}, {15, 5}, {2, 9}, {16, 6}, {7, 8}, {6, 8}, {16, 7}, {8, 10}, {3, 9}, {9, 8}, {12, 9}, {6, 9}, {11, 7}, {2, 10}, {16, 8}, {11, 8}, {6, 10}, {10, 9}, {15, 6}, {15, 7}, {3, 10}, {20, 10}, {5, 10}, {9, 9}, {10, 10}, {9, 10}, {14, 6}, {12, 10}, {13, 8}, {16, 9}, {14, 7}, {16, 10}, {15, 8}, {7, 9}, {13, 9}, {11, 9}, {13, 10}, {14, 8}, {1, 10}, {14, 9}, {14, 10}, {7, 10}, {15, 9}, {15, 10}, {11, 10}], {UNSIGNED1 i, UNSIGNED1 j});

srt := SORT(ds, i);

extds := TABLE(ds, {i, j, UNSIGNED1 k := 99});

extgrp := GROUP(SORTED(extds, k), k);

grpsrt := SORT(extgrp, i);

tpn := CHOOSEN(srt, 15);

grptpn := CHOOSEN(grpsrt, 15);

OUTPUT(srt, NAMED('sort'));
OUTPUT(grpsrt, NAMED('grouped_sort'));
OUTPUT(tpn, NAMED('topn'));
OUTPUT(grptpn, NAMED('grouped_topn'));
