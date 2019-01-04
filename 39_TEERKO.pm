# $Id$
############################################################################
#
# 39_TEERKO.pm
#
# Copyright (C) 2018 by Tim Sobisch
# e-mail: sobisch.t@gmail.com
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or 
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with fhem.  If not, see <http://www.gnu.org/licenses/>.
#
############################################################################


############################################################################
#
# Changelog:
# 2018-01-15, betav1.2.9
# fixed action prio checker when multi predicate_prefixes
#
# 2018-01-15, betav1.2.8
# fixed multiple detection (licht - lichter)
# change tokenizing for possible rooms matched < 0.5
#
# 2018-01-09, betav1.2.7
# Added some keys to actiontrigger open + close
#
# 2018-01-09, betav1.2.6
# Added colors "warmweiss" and "kaltweiss"
#
# 2018-01-09, betav1.2.5
# Added some Words to ignore
#
# 2018-01-09, betav1.2.4
# Fixed some Room Detectionbugs in RoomDevEliminiation
# Added Word "vom" as article
#
# 2018-01-09, betav1.2.3
# Added pm header
# New Internal Version
#
# 2018-01-09, betav1.2.2
# Added AMADDevice -All- to get all Devices
# Some Fixes
# 
############################################################################
package main;
use strict;
use warnings;
use Data::Dumper;
use Storable qw(dclone);
use Color;

my $modulversion = "1.0";

my %TEERKO_brain = (
    "vocabulary" => [
    # PREDICATE
        #switch
        {
            "type" => "predicate",
            "subtype" => "switch",
            "analysis"=> [
                {
                    "mappedtoken" => "schalt.{0,3}",
                    "cancelconjunjunction" => 1,
                    "brequired" => [],
                    "bforbidden" => [],
                    "arequired" => [],
                    "aforbidden" => [],
                }
            ]
        },
        #make
        {
            "type" => "predicate",
            "subtype" => "make",
            "analysis"=> [
                {
                    "mappedtoken" => "mach.{0,2}",
                    "cancelconjunjunction" => 1,
                    "brequired" => [],
                    "bforbidden" => [],
                    "arequired" => [],
                    "aforbidden" => [],
                }
            ]
        },
        #toggle
        {
            "type" => "predicate",
            "subtype" => "toggle",
            "analysis"=> [
                {
                    "mappedtoken" => "wechsel",
                    "cancelconjunjunction" => 1,
                    "brequired" => [],
                    "bforbidden" => [],
                    "arequired" => [],
                    "aforbidden" => [],
                }
            ]
        },
        #drive
        {
            "type" => "predicate",
            "subtype" => "drive",
            "analysis"=> [
                {
                    "mappedtoken" => "f(a|ä)hr.{0,2}",
                    "cancelconjunjunction" => 1,
                    "brequired" => [],
                    "bforbidden" => [],
                    "arequired" => [],
                    "aforbidden" => [],
                }
            ]
        },
        #setto
        {
            "type" => "predicate",
            "subtype" => "setto",
            "analysis"=> [
                {
                    "mappedtoken" => "(stell|setz).{0,2}",
                    "cancelconjunjunction" => 1,
                    "brequired" => [],
                    "bforbidden" => [],
                    "arequired" => [],
                    "aforbidden" => [],
                }
            ]
        },
        #setto
        {
            "type" => "predicate",
            "subtype" => "dim",
            "analysis"=> [
                {
                    "mappedtoken" => "dim.{0,3}",
                    "cancelconjunjunction" => 1,
                    "brequired" => [],
                    "bforbidden" => [],
                    "arequired" => [],
                    "aforbidden" => [],
                }
            ]
        },
        #say
        {
            "type" => "predicate",
            "subtype" => "say",
            "analysis"=> [
                {
                    "mappedtoken" => "sag.{0,2}",
                    "cancelconjunjunction" => 1,
                    "brequired" => [],
                    "bforbidden" => [],
                    "arequired" => [],
                    "aforbidden" => [],
                }
            ]
        },
        #show
        {
            "type" => "predicate",
            "subtype" => "show",
            "analysis"=> [
                {
                    "mappedtoken" => "zeig.{0,2}",
                    "cancelconjunjunction" => 1,
                    "brequired" => [],
                    "bforbidden" => [],
                    "arequired" => [],
                    "aforbidden" => [],
                }
            ]
        },
        #give
        {
            "type" => "predicate",
            "subtype" => "give",
            "analysis"=> [
                {
                    "mappedtoken" => "g(i|e)b.{0,2}",
                    "cancelconjunjunction" => 1,
                    "brequired" => [],
                    "bforbidden" => [],
                    "arequired" => [],
                    "aforbidden" => [],
                }
            ]
        },
        #call
        {
            "type" => "predicate",
            "subtype" => "call",
            "analysis"=> [
                {
                    "mappedtoken" => "nenn.{0,2}",
                    "cancelconjunjunction" => 1,
                    "brequired" => [],
                    "bforbidden" => [],
                    "arequired" => [],
                    "aforbidden" => [],
                }
            ]
        },
        #repeat
        {
            "type" => "predicate",
            "subtype" => "repeat",
            "analysis"=> [
                {
                    "mappedtoken" => "wiederhol.{0,2}",
                    "cancelconjunjunction" => 1,
                    "brequired" => [],
                    "bforbidden" => [],
                    "arequired" => [],
                    "aforbidden" => [],
                }
            ]
        },
        #be
        {
            "type" => "predicate",
            "subtype" => "be",
            "analysis"=> [
                {
                    "mappedtoken" => "(sein|bin|ist|sind)",
                    "cancelconjunjunction" => 1,
                    "brequired" => [],
                    "bforbidden" => [],
                    "arequired" => [],
                    "aforbidden" => [],
                }
            ]
        },
        #start
        {
            "type" => "predicate",
            "subtype" => "start",
            "analysis"=> [
                {
                    "mappedtoken" => "start.{0,3}",
                    "cancelconjunjunction" => 1,
                    "brequired" => [],
                    "bforbidden" => [],
                    "arequired" => [],
                    "aforbidden" => [],
                }
            ]
        },
        #begin
        {
            "type" => "predicate",
            "subtype" => "begin",
            "analysis"=> [
                {
                    "mappedtoken" => "beginn.{0,3}",
                    "cancelconjunjunction" => 1,
                    "brequired" => [],
                    "bforbidden" => [],
                    "arequired" => [],
                    "aforbidden" => [],
                }
            ]
        },
        #stop
        {
            "type" => "predicate",
            "subtype" => "stop",
            "analysis"=> [
                {
                    "mappedtoken" => "stop.{0,3}",
                    "cancelconjunjunction" => 1,
                    "brequired" => [],
                    "bforbidden" => [],
                    "arequired" => [],
                    "aforbidden" => [],
                }
            ]
        },
        #pause
        {
            "type" => "predicate",
            "subtype" => "pause",
            "analysis"=> [
                {
                    "mappedtoken" => "(anh(a|ä)lt|pausier).{0,2}",
                    "cancelconjunjunction" => 1,
                    "brequired" => [],
                    "bforbidden" => [],
                    "arequired" => [],
                    "aforbidden" => [],
                }
            ]
        },
        #play
        {
            "type" => "predicate",
            "subtype" => "play",
            "analysis"=> [
                {
                    "mappedtoken" => "(ab)?spiel.{0,2}",
                    "cancelconjunjunction" => 1,
                    "brequired" => [],
                    "bforbidden" => [],
                    "arequired" => [],
                    "aforbidden" => [],
                }
            ]
        },
        #open
        {
            "type" => "predicate",
            "subtype" => "open",
            "analysis"=> [
                {
                    "mappedtoken" => "öffne.{0,2}",
                    "cancelconjunjunction" => 1,
                    "brequired" => [],
                    "bforbidden" => [],
                    "arequired" => [],
                    "aforbidden" => [
                        "1:type:numericvalue"
                    ]
                }
            ]
        },
        #close
        {
            "type" => "predicate",
            "subtype" => "close",
            "analysis"=> [
                {
                    "mappedtoken" => "schlie(ss|ß).{0,3}",
                    "cancelconjunjunction" => 1,
                    "brequired" => [],
                    "bforbidden" => [],
                    "arequired" => [],
                    "aforbidden" => [],
                }
            ]
        },
        #close
        {
            "type" => "predicate",
            "subtype" => "color",
            "analysis"=> [
                {
                    "mappedtoken" => "einfärb.{0,3}|färbe",
                    "cancelconjunjunction" => 1,
                    "brequired" => [],
                    "bforbidden" => [],
                    "arequired" => [],
                    "aforbidden" => [],
                }
            ]
        },
    # PREDICATE_PREFIX
        #on
        {
            "type" => "predicate_prefix",
            "subtype" => "on",
            "analysis"=> [
                {
                    "mappedtoken" => "an|ein|einschalt.{0,3}|anmach.{0,3}",
                    "cancelconjunjunction" => 1,
                    "brequired" => [],
                    "bforbidden" => [],
                    "arequired" => [],
                    "aforbidden" => [
                        "1:type:article",
                    ],
                }
            ]
        },
        #off
        {
            "type" => "predicate_prefix",
            "subtype" => "off",
            "analysis"=> [
                {
                    "mappedtoken" => "aus|ausschalt.{0,3}|ausmach.{0,3}",
                    "cancelconjunjunction" => 1,
                    "brequired" => [],
                    "bforbidden" => [],
                    "arequired" => [],
                    "aforbidden" => [],
                }
            ]
        },
        #pct
        {
            "type" => "predicate_prefix",
            "subtype" => "pct",
            "analysis"=> [
                {
                    "mappedtoken" => "prozent",
                    "cancelconjunjunction" => 1,
                    "brequired" => [],
                    "bforbidden" => [],
                    "arequired" => [],
                    "aforbidden" => [],
                }
            ]
        },
        #open
        {
            "type" => "predicate_prefix",
            "subtype" => "open",
            "analysis"=> [
                {
                    "mappedtoken" => "auf",
                    "cancelconjunjunction" => 1,
                    "brequired" => [],
                    "bforbidden" => [],
                    "arequired" => [],
                    "aforbidden" => [
                        "1:type:article",
                        "1:type:numericvalue",
                        "1:type:colortable"
                    ]
                }
            ]
        },
        #close
        {
            "type" => "predicate_prefix",
            "subtype" => "close",
            "analysis"=> [
                {
                    "mappedtoken" => "zu",
                    "cancelconjunjunction" => 1,
                    "brequired" => [],
                    "bforbidden" => [],
                    "arequired" => [],
                    "aforbidden" => [],
                }
            ]
        },
        #up
        {
            "type" => "predicate_prefix",
            "subtype" => "up",
            "analysis"=> [
                {
                    "mappedtoken" => "hoch|hinauf|herauf|rauf|oben|hochfahr.{0,3}",
                    "cancelconjunjunction" => 1,
                    "brequired" => [],
                    "bforbidden" => [],
                    "arequired" => [],
                    "aforbidden" => [],
                }
            ]
        },
        #down
        {
            "type" => "predicate_prefix",
            "subtype" => "down",
            "analysis"=> [
                {
                    "mappedtoken" => "runter|hinab|herunter|unten|ab|runterfahr.{0,3}",
                    "cancelconjunjunction" => 1,
                    "brequired" => [],
                    "bforbidden" => [],
                    "arequired" => [],
                    "aforbidden" => [],
                }
            ]
        },
        #toggle
        {
            "type" => "predicate_prefix",
            "subtype" => "toggle",
            "analysis"=> [
                {
                    "mappedtoken" => "um",
                    "cancelconjunjunction" => 1,
                    "brequired" => [],
                    "bforbidden" => [],
                    "arequired" => [],
                    "aforbidden" => [],
                }
            ]
        },
        #repeat
        {
            "type" => "predicate_prefix",
            "subtype" => "repeat",
            "analysis"=> [
                {
                    "mappedtoken" => "nochmal",
                    "cancelconjunjunction" => 1,
                    "brequired" => [],
                    "bforbidden" => [],
                    "arequired" => [],
                    "aforbidden" => [],
                },
                {
                    "mappedtoken" => "noch",
                    "cancelconjunjunction" => 1,
                    "brequired" => [],
                    "bforbidden" => [],
                    "arequired" => [
                        "1:token:mal"
                    ],
                    "aforbidden" => [],
                },
                {
                    "mappedtoken" => "mal",
                    "cancelconjunjunction" => 1,
                    "brequired" => [
                        "1:token:noch"
                    ],
                    "bforbidden" => [],
                    "arequired" => [],
                    "aforbidden" => [],
                }
            ]
        },
    # T Preposition
        #tpreposition
        {
            "type" => "tpreposition",
            "subtype" => "tpreposition",
            "analysis"=> [
                {
                    "mappedtoken" => "in",
                    "cancelconjunjunction" => 1,
                    "brequired" => [],
                    "bforbidden" => [],
                    "arequired" => [
                        "1:type:numericvalue",
                        "1:subtype:minute"
                    ],
                    "aforbidden" => [],
                },
                {
                    "mappedtoken" => "in",
                    "cancelconjunjunction" => 1,
                    "brequired" => [],
                    "bforbidden" => [],
                    "arequired" => [
                        "1:type:numericvalue",
                        "1:subtype:hour"
                    ],
                    "aforbidden" => [],
                },
                {
                    "mappedtoken" => "in",
                    "cancelconjunjunction" => 1,
                    "brequired" => [],
                    "bforbidden" => [],
                    "arequired" => [
                        "1:type:numericvalue",
                        "1:subtype:second"
                    ],
                    "aforbidden" => [],
                }
            ]
        },
    # R Preposition
        #rpreposition
        {
            "type" => "rpreposition",
            "subtype" => "rpreposition",
            "analysis"=> [
                {
                    "mappedtoken" => "im|zum",
                    "cancelconjunjunction" => 1,
                    "brequired" => [],
                    "bforbidden" => [],
                    "arequired" => [],
                    "aforbidden" => [
                        "1:token:\\d+"
                    ]
                },
                {
                    "mappedtoken" => "auf|in",
                    "cancelconjunjunction" => 1,
                    "brequired" => [],
                    "bforbidden" => [],
                    "arequired" => [
                        #"1:token:der"
                    ],
                    "aforbidden" => [
                        "1:type:numericvalue",
                        "1:subtype:(minute|second|hour|normal)"
                    ]
                },
                {
                    "mappedtoken" => "an",
                    "cancelconjunjunction" => 1,
                    "brequired" => [],
                    "bforbidden" => [],
                    "arequired" => [
                        "1:type:article",
                    ],
                    "aforbidden" => []
                }
            ]
        },
    # Article
        #article
        {
            "type" => "article",
            "subtype" => "article",
            "analysis"=> [
                {
                    "mappedtoken" => "der|die|das|des|den|dem|vom",
                    "cancelconjunjunction" => 1,
                    "brequired" => [],
                    "bforbidden" => [],
                    "arequired" => [],
                    "aforbidden" => [],
                }
            ]
        },
    # Pronoun
        #multi
        {
            "type" => "pronoun",
            "subtype" => "multiple",
            "analysis"=> [
                {
                    "mappedtoken" => "alle|jede|jedes|jeder|sämtliche|aller",
                    "cancelconjunjunction" => 1,
                    "brequired" => [],
                    "bforbidden" => [],
                    "arequired" => [],
                    "aforbidden" => [],
                }
            ]
        },
    # Conjunction
        #conjunction
        {
            "type" => "conjunction",
            "subtype" => "and",
            "analysis"=> [
                {
                    "mappedtoken" => "und",
                    "cancelconjunjunction" => 0,
                    "brequired" => [],
                    "bforbidden" => [],
                    "arequired" => [],
                    "aforbidden" => [],
                }
            ]
        },
    # Dot, Comma
        #dot
        {
            "type" => "dot",
            "subtype" => "dot",
            "analysis"=> [
                {
                    "mappedtoken" => "\\.",
                    "cancelconjunjunction" => 0,
                    "brequired" => [],
                    "bforbidden" => [],
                    "arequired" => [],
                    "aforbidden" => [],
                }
            ]
        },
        #comma
        {
            "type" => "comma",
            "subtype" => "comma",
            "analysis"=> [
                {
                    "mappedtoken" => "\\,",
                    "cancelconjunjunction" => 0,
                    "brequired" => [],
                    "bforbidden" => [],
                    "arequired" => [],
                    "aforbidden" => [],
                }
            ]
        },
    # advmod
        #advmod
        {
            "type" => "advmod",
            "subtype" => "advmod",
            "analysis"=> [
                {
                    "mappedtoken" => "wie",
                    "cancelconjunjunction" => 1,
                    "brequired" => [],
                    "bforbidden" => [],
                    "arequired" => [],
                    "aforbidden" => [],
                }
            ]
        },
    # rooms
        #room
        {
            "type" => "room",
            "subtype" => "room",
            "analysis"=> [
                {
                    "mappedtoken" => "wohnzimmer|esszimmer|küchen|küche|badezimmer|keller|schlafzimmer|flur|gästezimmer|schuppen|abstellkammer|stube|stuben",
                    "cancelconjunjunction" => 1,
                    "brequired" => [],
                    "bforbidden" => [],
                    "arequired" => [],
                    "aforbidden" => [],
                }
            ]
        },
    # Time Units
        #second
        {
            "type" => "timeunit",
            "subtype" => "second",
            "analysis"=> [
                {
                    "mappedtoken" => "Sekunde.{0,1}",
                    "cancelconjunjunction" => 1,
                    "brequired" => [],
                    "bforbidden" => [],
                    "arequired" => [],
                    "aforbidden" => [],
                }
            ]
        },
        #miinute
        {
            "type" => "timeunit",
            "subtype" => "minute",
            "analysis"=> [
                {
                    "mappedtoken" => "minute.{0,1}",
                    "cancelconjunjunction" => 1,
                    "brequired" => [],
                    "bforbidden" => [],
                    "arequired" => [],
                    "aforbidden" => [],
                }
            ]
        },
        #hour
        {
            "type" => "timeunit",
            "subtype" => "hour",
            "analysis"=> [
                {
                    "mappedtoken" => "Stunde.{0,1}",
                    "cancelconjunjunction" => 1,
                    "brequired" => [],
                    "bforbidden" => [],
                    "arequired" => [],
                    "aforbidden" => [],
                }
            ]
        },
    # Numeric Value
        #second
        {
            "type" => "numericvalue",
            "subtype" => "second",
            "analysis"=> [
                {
                    "mappedtoken" => "\\d+",
                    "cancelconjunjunction" => 1,
                    "brequired" => [],
                    "bforbidden" => [],
                    "arequired" => [
                        "1:type:timeunit",
                        "1:subtype:second"
                    ],
                    "aforbidden" => [],
                }
            ]
        },
        #minute
        {
            "type" => "numericvalue",
            "subtype" => "minute",
            "analysis"=> [
                {
                    "mappedtoken" => "\\d+",
                    "cancelconjunjunction" => 1,
                    "brequired" => [],
                    "bforbidden" => [],
                    "arequired" => [
                        "1:type:timeunit",
                        "1:subtype:minute"
                    ],
                    "aforbidden" => [],
                }
            ]
        },
        #hour
        {
            "type" => "numericvalue",
            "subtype" => "hour",
            "analysis"=> [
                {
                    "mappedtoken" => "\\d+",
                    "cancelconjunjunction" => 1,
                    "brequired" => [],
                    "bforbidden" => [],
                    "arequired" => [
                        "1:type:timeunit",
                        "1:subtype:hour"
                    ],
                    "aforbidden" => [],
                }
            ]
        },
        #normal
        {
            "type" => "numericvalue",
            "subtype" => "normal",
            "analysis"=> [
                {
                    "mappedtoken" => "\\d+",
                    "cancelconjunjunction" => 1,
                    "brequired" => [],
                    "bforbidden" => [],
                    "arequired" => [],
                    "aforbidden" => [
                        "1:type:timeunit"
                    ]
                }
            ]
        },
    # Special Nouns
        #state
        {
            "type" => "special_noun",
            "subtype" => "state",
            "analysis"=> [
                {
                    "mappedtoken" => "status|stati|zustand",
                    "cancelconjunjunction" => 1,
                    "brequired" => [],
                    "bforbidden" => [],
                    "arequired" => [],
                    "aforbidden" => [],
                }
            ]
        },
        #command
        {
            "type" => "special_noun",
            "subtype" => "command",
            "analysis"=> [
                {
                    "mappedtoken" => "befehl|kommando|befehle",
                    "cancelconjunjunction" => 1,
                    "brequired" => [],
                    "bforbidden" => [],
                    "arequired" => [],
                    "aforbidden" => [],
                }
            ]
        },
        #command
        {
            "type" => "special_noun",
            "subtype" => "color",
            "analysis"=> [
                {
                    "mappedtoken" => "Farbe",
                    "cancelconjunjunction" => 1,
                    "brequired" => [],
                    "bforbidden" => [],
                    "arequired" => [],
                    "aforbidden" => [],
                }
            ]
        },
        #device
        {
            "type" => "special_noun",
            "subtype" => "device",
            "analysis"=> [
                {
                    "mappedtoken" => "(Gerät|objekt|ding|teil|aktor|sensor).{0,3}",
                    "cancelconjunjunction" => 1,
                    "brequired" => [],
                    "bforbidden" => [],
                    "arequired" => [],
                    "aforbidden" => [],
                }
            ]
        },
        #playlist
        {
            "type" => "special_noun",
            "subtype" => "playlist",
            "analysis"=> [
                {
                    "mappedtoken" => "(Playlist|Abspiellist).{0,2}",
                    "cancelconjunjunction" => 1,
                    "brequired" => [],
                    "bforbidden" => [],
                    "arequired" => [],
                    "aforbidden" => [],
                },
                {
                    "mappedtoken" => "(Play|Abspiel)",
                    "cancelconjunjunction" => 1,
                    "brequired" => [],
                    "bforbidden" => [],
                    "arequired" => [
                        "1:token:list.{0,2}"
                    ],
                    "aforbidden" => [],
                },
                {
                    "mappedtoken" => "list.{0,2}",
                    "cancelconjunjunction" => 1,
                    "brequired" => [
                        "1:token:\(Play\|Abspiel\)"
                    ],
                    "bforbidden" => [],
                    "arequired" => [],
                    "aforbidden" => [],
                }
            ]
        },
        #temperature
        {
            "type" => "special_noun",
            "subtype" => "temperature",
            "analysis"=> [
                {
                    "mappedtoken" => "temperatur",
                    "cancelconjunjunction" => 1,
                    "brequired" => [],
                    "bforbidden" => [],
                    "arequired" => [],
                    "aforbidden" => [],
                }
            ]
        },
        #systeminformation
        {
            "type" => "special_noun",
            "subtype" => "systeminformation",
            "analysis"=> [
                {
                    "mappedtoken" => "Systeminformation.{0,2}",
                    "cancelconjunjunction" => 1,
                    "brequired" => [],
                    "bforbidden" => [],
                    "arequired" => [],
                    "aforbidden" => [],
                }
            ]
        },
        #information
        {
            "type" => "special_noun",
            "subtype" => "information",
            "analysis"=> [
                {
                    "mappedtoken" => "Information.{0,2}|info.{0,1}",
                    "cancelconjunjunction" => 1,
                    "brequired" => [],
                    "bforbidden" => [],
                    "arequired" => [],
                    "aforbidden" => [],
                }
            ]
        },
        #volume
        {
            "type" => "special_noun",
            "subtype" => "volume",
            "analysis"=> [
                {
                    "mappedtoken" => "Lautstärke",
                    "cancelconjunjunction" => 1,
                    "brequired" => [],
                    "bforbidden" => [],
                    "arequired" => [],
                    "aforbidden" => [],
                }
            ]
        },
        #music
        {
            "type" => "special_noun",
            "subtype" => "music",
            "analysis"=> [
                {
                    "mappedtoken" => "musik",
                    "cancelconjunjunction" => 1,
                    "brequired" => [],
                    "bforbidden" => [],
                    "arequired" => [],
                    "aforbidden" => [],
                }
            ]
        },
        #sonos
        {
            "type" => "special_noun",
            "subtype" => "sonos",
            "analysis"=> [
                {
                    "mappedtoken" => "sonos|sonosbox|sonossystem|sonosboxen",
                    "cancelconjunjunction" => 1,
                    "brequired" => [],
                    "bforbidden" => [],
                    "arequired" => [],
                    "aforbidden" => [],
                }
            ]
        },
        #track
        {
            "type" => "special_noun",
            "subtype" => "track",
            "analysis"=> [
                {
                    "mappedtoken" => "song|lied|track",
                    "cancelconjunjunction" => 1,
                    "brequired" => [],
                    "bforbidden" => [],
                    "arequired" => [],
                    "aforbidden" => [],
                }
            ]
        },
    #adjective
        #temp
        {
            "type" => "adjective",
            "subtype" => "temperature",
            "analysis"=> [
                {
                    "mappedtoken" => "warm|kalt",
                    "cancelconjunjunction" => 1,
                    "brequired" => [],
                    "bforbidden" => [],
                    "arequired" => [],
                    "aforbidden" => [],
                }
            ]
        },
        #mute
        {
            "type" => "adjective",
            "subtype" => "mute",
            "analysis"=> [
                {
                    "mappedtoken" => "lautlos|mute",
                    "cancelconjunjunction" => 1,
                    "brequired" => [],
                    "bforbidden" => [],
                    "arequired" => [],
                    "aforbidden" => [],
                }
            ]
        },
        #next
        {
            "type" => "adjective",
            "subtype" => "next",
            "analysis"=> [
                {
                    "mappedtoken" => "(nächste|folgende|kommende).{0,1}",
                    "cancelconjunjunction" => 1,
                    "brequired" => [],
                    "bforbidden" => [],
                    "arequired" => [],
                    "aforbidden" => [],
                }
            ]
        },
        #previous
        {
            "type" => "adjective",
            "subtype" => "previous",
            "analysis"=> [
                {
                    "mappedtoken" => "(vorherige|davor).{0,1}",
                    "cancelconjunjunction" => 1,
                    "brequired" => [],
                    "bforbidden" => [],
                    "arequired" => [],
                    "aforbidden" => [],
                }
            ]
        },
    #colortable
        #yellow
        {
            "type" => "colortable",
            "subtype" => "en:yellow;de:Gelb;hex:ffff00",
            "analysis"=> [
                {
                    "mappedtoken" => "gelb",
                    "cancelconjunjunction" => 1,
                    "brequired" => [],
                    "bforbidden" => [],
                    "arequired" => [],
                    "aforbidden" => [],
                }
            ]
        },
        #weiss
        {
            "type" => "colortable",
            "subtype" => "en:white;de:Weiss;hex:ffffff",
            "analysis"=> [
                {
                    "mappedtoken" => "wei(ß|ss)",
                    "cancelconjunjunction" => 1,
                    "brequired" => [],
                    "bforbidden" => [],
                    "arequired" => [],
                    "aforbidden" => [],
                }
            ]
        },
        #warmweiss
        {
            "type" => "colortable",
            "subtype" => "en:warmwhite;de:Warmeiss;hex:f3e7d3",
            "analysis"=> [
                {
                    "mappedtoken" => "warmwei(ß|ss)",
                    "cancelconjunjunction" => 1,
                    "brequired" => [],
                    "bforbidden" => [],
                    "arequired" => [],
                    "aforbidden" => [],
                }
            ]
        },
        #kaltweiss
        {
            "type" => "colortable",
            "subtype" => "en:coldwhite;de:Kaltweiss;hex:f8f8f8",
            "analysis"=> [
                {
                    "mappedtoken" => "kaltwei(ß|ss)",
                    "cancelconjunjunction" => 1,
                    "brequired" => [],
                    "bforbidden" => [],
                    "arequired" => [],
                    "aforbidden" => [],
                }
            ]
        },
        #orange
        {
            "type" => "colortable",
            "subtype" => "en:orange;de:Orange;hex:ffa500",
            "analysis"=> [
                {
                    "mappedtoken" => "orange",
                    "cancelconjunjunction" => 1,
                    "brequired" => [],
                    "bforbidden" => [],
                    "arequired" => [],
                    "aforbidden" => [],
                }
            ]
        },
        #magenta
        {
            "type" => "colortable",
            "subtype" => "en:magenta;de:Magenta;hex:ff00ff",
            "analysis"=> [
                {
                    "mappedtoken" => "magenta",
                    "cancelconjunjunction" => 1,
                    "brequired" => [],
                    "bforbidden" => [],
                    "arequired" => [],
                    "aforbidden" => [],
                }
            ]
        },
        #red
        {
            "type" => "colortable",
            "subtype" => "en:red;de:Rot;hex:ff0000",
            "analysis"=> [
                {
                    "mappedtoken" => "rot",
                    "cancelconjunjunction" => 1,
                    "brequired" => [],
                    "bforbidden" => [],
                    "arequired" => [],
                    "aforbidden" => [],
                }
            ]
        },
        #violett
        {
            "type" => "colortable",
            "subtype" => "en:purple;de:vioelett;hex:800080",
            "analysis"=> [
                {
                    "mappedtoken" => "violett",
                    "cancelconjunjunction" => 1,
                    "brequired" => [],
                    "bforbidden" => [],
                    "arequired" => [],
                    "aforbidden" => [],
                }
            ]
        },
        #blue
        {
            "type" => "colortable",
            "subtype" => "en:blue;de:Blau;hex:0000ff",
            "analysis"=> [
                {
                    "mappedtoken" => "blau",
                    "cancelconjunjunction" => 1,
                    "brequired" => [],
                    "bforbidden" => [],
                    "arequired" => [],
                    "aforbidden" => [],
                }
            ]
        },
        #cyan
        {
            "type" => "colortable",
            "subtype" => "en:cyan;de:Türkis;hex:00ffff",
            "analysis"=> [
                {
                    "mappedtoken" => "türkis",
                    "cancelconjunjunction" => 1,
                    "brequired" => [],
                    "bforbidden" => [],
                    "arequired" => [],
                    "aforbidden" => [],
                }
            ]
        },
        #green
        {
            "type" => "colortable",
            "subtype" => "en:green;de:Grün;hex:008000",
            "analysis"=> [
                {
                    "mappedtoken" => "grün",
                    "cancelconjunjunction" => 1,
                    "brequired" => [],
                    "bforbidden" => [],
                    "arequired" => [],
                    "aforbidden" => [],
                }
            ]
        },
        #black
        {
            "type" => "colortable",
            "subtype" => "en:black;de:Schwarz;hex:000000",
            "analysis"=> [
                {
                    "mappedtoken" => "schwarz",
                    "cancelconjunjunction" => 1,
                    "brequired" => [],
                    "bforbidden" => [],
                    "arequired" => [],
                    "aforbidden" => [],
                }
            ]
        },
        #grau
        {
            "type" => "colortable",
            "subtype" => "en:grey;de:Grau;hex:808080",
            "analysis"=> [
                {
                    "mappedtoken" => "grau",
                    "cancelconjunjunction" => 1,
                    "brequired" => [],
                    "bforbidden" => [],
                    "arequired" => [],
                    "aforbidden" => [],
                }
            ]
        },
        #braun
        {
            "type" => "colortable",
            "subtype" => "en:brown;de:Braun;hex:A52A2A",
            "analysis"=> [
                {
                    "mappedtoken" => "grau",
                    "cancelconjunjunction" => 1,
                    "brequired" => [],
                    "bforbidden" => [],
                    "arequired" => [],
                    "aforbidden" => [],
                }
            ]
        },
        #rosa
        {
            "type" => "colortable",
            "subtype" => "en:Pink;de:Rosa;hex:FFC0CB",
            "analysis"=> [
                {
                    "mappedtoken" => "rosa|pink",
                    "cancelconjunjunction" => 1,
                    "brequired" => [],
                    "bforbidden" => [],
                    "arequired" => [],
                    "aforbidden" => [],
                }
            ]
        },
    #irrelevant words...IGNORE
        #all
        {
            "type" => "ignore",
            "subtype" => "token",
            "analysis"=> [
                {
                    "mappedtoken" => "auf",
                    "cancelconjunjunction" => 1,
                    "brequired" => [],
                    "bforbidden" => [],
                    "arequired" => [
                        "1:type:numericvalue"
                    ],
                    "aforbidden" => [],
                },
                {
                    "mappedtoken" => "ab",
                    "cancelconjunjunction" => 1,
                    "brequired" => [],
                    "bforbidden" => [],
                    "arequired" => [],
                    "aforbidden" => [],
                },
                {
                    "mappedtoken" => "ich|du|er|sie|es",
                    "cancelconjunjunction" => 1,
                    "brequired" => [],
                    "bforbidden" => [],
                    "arequired" => [],
                    "aforbidden" => [],
                },
                {
                    "mappedtoken" => "mir|mich",
                    "cancelconjunjunction" => 1,
                    "brequired" => [],
                    "bforbidden" => [],
                    "arequired" => [],
                    "aforbidden" => [],
                },
                {
                    "mappedtoken" => "möcht.*|mag.*|gern.*|welch.*|will.*",
                    "cancelconjunjunction" => 1,
                    "brequired" => [],
                    "bforbidden" => [],
                    "arequired" => [],
                    "aforbidden" => [],
                }
            ]
        },
    ],
    "actions" => [
    #BASIC
        #mode 0 - FAIL
        {
            "type" => "none",
            "function"=>\&TEERKO_FailCMD,
            "classification"=>[
                {
                    "prio"=>0,
                    "required" => [
                        ".*"
                    ],
                    "forbidden" => [],
                }
            ],
            "moderequired" => 0,
        },
        #mode 0 - turn on
        {
            "type" => "seton" ,
            "default_param" => [
                "on"
            ],
            "function"=>\&TEERKO_BasicCMD,
            "classification"=>[
                {
                    "prio"=>1,
                    "required" => [
                        "type:predicate_prefix:subtype:on"
                    ],
                    "forbidden" => [],
                },
                {
                    "prio"=>30,
                    "required" => [
                        "type:predicate_prefix:subtype:on",
                        "type:predicate:subtype:(switch|make)"
                    ],
                    "forbidden" => [],
                },

            ],
            "moderequired" => 0,
            "response" => {
                "normal_success" => [
                    "Ich habe %DAFP% %ALIAS% eingeschaltet."
                ],
                "normal_success_room" => [
                    "Ich habe %DAFP% %ALIAS% %RPP% %ROOM% eingeschaltet."
                ],
                "normal_success_sleep" => [
                    "Ich werde %DAFP% %ALIAS% %SLEEP% einschalten."
                ],
                "normal_success_room_sleep" => [
                    "Ich werde %DAFP% %ALIAS% %RPP% %ROOM% %SLEEP% einschalten.",
                ],
            },
        },
        #mode 0 - turn off
        {
            "type" => "setoff" ,
            "default_param" => [
                "off"
            ],
            "function"=>\&TEERKO_BasicCMD,
            "classification"=>[
                {
                    "prio"=>29,
                    "required" => [
                        "type:predicate_prefix:subtype:off"
                    ],
                    "forbidden" => [],
                },
                {
                    "prio"=>59,
                    "required" => [
                        "type:predicate_prefix:subtype:off",
                        "type:predicate:subtype:(switch|make)"
                    ],
                    "forbidden" => [],
                }
            ],
            "moderequired" => 0,
            "response" => {
                "normal_success" => [
                    "Ich habe %DAFP% %ALIAS% ausgeschaltet."
                ],
                "normal_success_room" => [
                    "Ich habe %DAFP% %ALIAS% %RPP% %ROOM% ausgeschaltet."
                ],
                "normal_success_sleep" => [
                    "Ich werde %DAFP% %ALIAS% %SLEEP% ausschalten."
                ],
                "normal_success_room_sleep" => [
                    "Ich werde %DAFP% %ALIAS% %RPP% %ROOM% %SLEEP% ausschalten.",
                ],
            },
        },
        #mode 0 - drive up
        {
            "type" => "setup" ,
            "default_param" => [
                "up"
            ],
            "function"=>\&TEERKO_BasicCMD,
            "classification"=>[
                {
                    "prio"=>2,
                    "required" => [
                        "type:predicate_prefix:subtype:up"
                    ],
                    "forbidden" => [],
                },
                {
                    "prio"=>31,
                    "required" => [
                        "type:predicate_prefix:subtype:up",
                        "type:predicate:subtype:(drive)"
                    ],
                    "forbidden" => [],
                },
            ],
            "moderequired" => 0,
            "response" => {
                "normal_success" => [
                    "Ich habe %DAFP% %ALIAS% hochgefahren."
                ],
                "normal_success_room" => [
                    "Ich habe %DAFP% %ALIAS% %RPP% %ROOM% hochgefahren."
                ],
                "normal_success_sleep" => [
                    "Ich werde %DAFP% %ALIAS% %SLEEP% hochfahren."
                ],
                "normal_success_room_sleep" => [
                    "Ich werde %DAFP% %ALIAS% %RPP% %ROOM% %SLEEP% hochfahren.",
                ],
            },
        },
        #mode 0 - drive down
        {
            "type" => "setdown" ,
            "default_param" => [
                "down"
            ],
            "function"=>\&TEERKO_BasicCMD,
            "classification"=>[
                {
                    "prio"=>28,
                    "required" => [
                        "type:predicate_prefix:subtype:down"
                    ],
                    "forbidden" => [],
                },
                {
                    "prio"=>58,
                    "required" => [
                        "type:predicate_prefix:subtype:down",
                        "type:predicate:subtype:(drive)"
                    ],
                    "forbidden" => [],
                },
            ],
            "moderequired" => 0,
            "response" => {
                "normal_success" => [
                    "Ich habe %DAFP% %ALIAS% runtergefahren."
                ],
                "normal_success_room" => [
                    "Ich habe %DAFP% %ALIAS% %RPP% %ROOM% runtergefahren."
                ],
                "normal_success_sleep" => [
                    "Ich werde %DAFP% %ALIAS% %SLEEP% runterfahren."
                ],
                "normal_success_room_sleep" => [
                    "Ich werde %DAFP% %ALIAS% %RPP% %ROOM% %SLEEP% runterfahren.",
                ],
            },
        },
        #mode 0 - start
        {
            "type" => "setstart" ,
            "default_param" => [
                "start"
            ],
            "function"=>\&TEERKO_BasicCMD,
            "classification"=>[
                {
                    "prio"=>34,
                    "required" => [
                        "type:predicate:subtype:(start)"
                    ],
                    "forbidden" => [],
                },
            ],
            "moderequired" => 0,
            "response" => {
                "normal_success" => [
                    "Ich habe %DAFP% %ALIAS% gestartet."
                ],
                "normal_success_room" => [
                    "Ich habe %DAFP% %ALIAS% %RPP% %ROOM% gestartet."
                ],
                "normal_success_sleep" => [
                    "Ich werde %DAFP% %ALIAS% %SLEEP% starten."
                ],
                "normal_success_room_sleep" => [
                    "Ich werde %DAFP% %ALIAS% %RPP% %ROOM% %SLEEP% starten.",
                ],
            },
        },
        #mode 0 - stop
        {
            "type" => "setstop" ,
            "default_param" => [
                "stop"
            ],
            "function"=>\&TEERKO_BasicCMD,
            "classification"=>[
                {
                    "prio"=>56,
                    "required" => [
                        "type:predicate:subtype:(stop)"
                    ],
                    "forbidden" => [],
                },
            ],
            "moderequired" => 0,
            "response" => {
                "normal_success" => [
                    "Ich habe %DAFP% %ALIAS% gestoppt."
                ],
                "normal_success_room" => [
                    "Ich habe %DAFP% %ALIAS% %RPP% %ROOM% gestoppt."
                ],
                "normal_success_sleep" => [
                    "Ich werde %DAFP% %ALIAS% %SLEEP% stoppen."
                ],
                "normal_success_room_sleep" => [
                    "Ich werde %DAFP% %ALIAS% %RPP% %ROOM% %SLEEP% stoppen.",
                ],
            },
        },
        #mode 0 - open
        {
            "type" => "setopen" ,
            "default_param" => [
                "open"
            ],
            "function"=>\&TEERKO_BasicCMD,
            "classification"=>[
                {
                    "prio"=>3,
                    "required" => [
                        "type:predicate_prefix:subtype:open"
                    ],
                    "forbidden" => [],
                },
                {
                    "prio"=>32,
                    "required" => [
                        "type:predicate:subtype:(switch|make|close)",
                        "type:predicate_prefix:subtype:open"
                    ],
                    "forbidden" => [],
                },
                {
                    "prio"=>32,
                    "required" => [
                        "type:predicate:subtype:open",
                    ],
                    "forbidden" => [],
                },
                
            ],
            "moderequired" => 0,
            "response" => {
                "normal_success" => [
                    "Ich habe %DAFP% %ALIAS% geöffnet."
                ],
                "normal_success_room" => [
                    "Ich habe %DAFP% %ALIAS% %RPP% %ROOM% geöffnet."
                ],
                "normal_success_sleep" => [
                    "Ich werde %DAFP% %ALIAS% %SLEEP% öffnen."
                ],
                "normal_success_room_sleep" => [
                    "Ich werde %DAFP% %ALIAS% %RPP% %ROOM% %SLEEP% öffnen.",
                ],
            },
        },
        #mode 0 - close
        {
            "type" => "setclose" ,
            "default_param" => [
                "close"
            ],
            "function"=>\&TEERKO_BasicCMD,
            "classification"=>[
                {
                    "prio"=>27,
                    "required" => [
                        "type:predicate_prefix:subtype:close"
                    ],
                    "forbidden" => [],
                },
                {
                    "prio"=>57,
                    "required" => [
                        "type:predicate:subtype:(switch|make|close)",
                        "type:predicate_prefix:subtype:close"
                    ],
                    "forbidden" => [],
                },
                {
                    "prio"=>57,
                    "required" => [
                        "type:predicate:subtype:(close)",
                        "type:predicate_prefix:subtype:down"
                    ],
                    "forbidden" => [],
                },
                {
                    "prio"=>57,
                    "required" => [
                        "type:predicate:subtype:close",
                    ],
                    "forbidden" => [],
                },
                
            ],
            "moderequired" => 0,
            "response" => {
                "normal_success" => [
                    "Ich habe %DAFP% %ALIAS% geschlossen."
                ],
                "normal_success_room" => [
                    "Ich habe %DAFP% %ALIAS% %RPP% %ROOM% geschlossen."
                ],
                "normal_success_sleep" => [
                    "Ich werde %DAFP% %ALIAS% %SLEEP% schließen."
                ],
                "normal_success_room_sleep" => [
                    "Ich werde %DAFP% %ALIAS% %RPP% %ROOM% %SLEEP% schließen.",
                ],
            },
        },
        #mode 0 - pct
        {
            "type" => "setpct" ,
            "default_param" => [
                "pct",
                "%INT%"
            ],
            "function"=>\&TEERKO_BasicCMD,
            "classification"=>[
                {
                    "prio"=>15,
                    "required" => [
                        "type:numericvalue:subtype:normal"
                    ],
                    "forbidden" => [],
                },
                {
                    "prio"=>45,
                    "required" => [
                        "type:numericvalue:subtype:normal",
                        "type:predicate:subtype:drive"
                    ],
                    "forbidden" => [],
                    "response" => {
                        "normal_success" => [
                            "%ALIAS% auf den Wert %INT% gefahren. ",
                        ],
                    },
                },
                {
                    "prio"=>45,
                    "required" => [
                        "type:numericvalue:subtype:normal",
                        "type:predicate:subtype:setto"
                    ],
                    "forbidden" => [],
                    "response" => {
                        "normal_success" => [
                            "%ALIAS% auf den Wert %INT% gestellt. ",
                        ],
                    },
                },
                {
                    "prio"=>45,
                    "required" => [
                        "type:numericvalue:subtype:normal",
                        "type:predicate:subtype:dim"
                    ],
                    "forbidden" => [],
                    "response" => {
                        "normal_success" => [
                            "%ALIAS% auf den Wert %INT% gedimmt. ",
                        ],
                    },
                }
                
            ],
            "moderequired" => 0,
            "response" => {
                "normal_success" => [
                    "Ich habe %DAFP% %ALIAS% auf %INT% eingestellt."
                ],
                "normal_success_room" => [
                    "Ich habe %DAFP% %ALIAS% %RPP% %ROOM% auf %INT% eingestellt."
                ],
                "normal_success_sleep" => [
                    "Ich werde %DAFP% %ALIAS% %SLEEP% auf %INT% einstellen."
                ],
                "normal_success_room_sleep" => [
                    "Ich werde %DAFP% %ALIAS% %RPP% %ROOM% %SLEEP% auf %INT% einstellen."
                ],
            },
        },
        #mode 0 - color
        {
            "type" => "setcolor" ,
            "default_param" => [
                "rgb",
                "%CRGB%"
            ],
            "function"=>\&TEERKO_BasicCMD,
            "classification"=>[
                {
                    "prio"=>4,
                    "required" => [
                        "type:colortable"
                    ],
                    "forbidden" => [],
                },
                {
                    "prio"=>33,
                    "required" => [
                        "type:colortable",
                        "type:predicate:subtype:color"
                    ],
                    "forbidden" => [],
                },
                {
                    "prio"=>33,
                    "required" => [
                        "type:colortable",
                        "type:predicate:subtype:setto"
                    ],
                    "forbidden" => [],
                },
                {
                    "prio"=>33,
                    "required" => [
                        "type:colortable",
                        "type:predicate:subtype:(switch|make)"
                    ],
                    "forbidden" => [],
                }
                
            ],
            "moderequired" => 0,
            "response" => {
                "normal_success" => [
                    "Ich habe %DAFP% %ALIAS% auf %CDE% eingestellt."
                ],
                "normal_success_room" => [
                    "Ich habe %DAFP% %ALIAS% %RPP% %ROOM% auf %CDE% eingestellt."
                ],
                "normal_success_sleep" => [
                    "Ich werde %DAFP% %ALIAS% %SLEEP% auf %CDE% einstellen."
                ],
                "normal_success_room_sleep" => [
                    "Ich werde %DAFP% %ALIAS% %RPP% %ROOM% %SLEEP% auf %CDE% einstellen."
                ],
            },
        },
        #mode 0 - GetState
        {
            "type" => "getstate" ,
            "default_param" => [
                "state"
            ],
            "function"=>\&TEERKO_GetState,
            "classification"=>[
                {
                    "prio"=>90,
                    "required" => [
                        "type:special_noun:subtype:state"
                    ],
                    "forbidden" => [],
                }
                
            ],
            "moderequired" => 0,
            "response" => {
                "normal_success" => [
                    "%DAFP% %ALIAS% ist %STATE%. ",
                    "Der Status %DASP% %ALIAS% ist %STATE%. ",
                ],
                "normal_success_room" => [
                    "%DAFP% %ALIAS% %RPP% %ROOM% ist %STATE%. ",
                    "Der Status %DASP% %ALIAS% %RPP% %ROOM% ist %STATE%. ",
                ],
            },
        },
    ],
    "responsetext" => {
        "err_noright"=>[
            "Das Gerät %ALIAS% darf ich nicht kontrollieren. Kontrolliere das Attribute TEERKOAllowedToControl ob das Gerät dort vorhanden ist.",
            "Gib mir zuerst die Berechtigung %ALIAS% zu bedienen. Das kannst du in dem Attribut TEERKOAllowedToControl",
            "%ALIAS% darf ich nicht steuern. Dazu musst du das Attribut TEERKOAllowedToControl bearbeiten."
        ],
        "err_nocombination"=>[
            "Die Kombination an Wörtern verstehe ich nicht.",
            "Ich weiß leider nicht was ich machen soll.",
            "Ich verstehe das nicht. "
        ],
        "err_norooms"=>[
            "Du hast keine Räume definiert. Bitte vergib den Geräten Raumnamen.",
            "Keine Räume gefunden. Da musst du schon welche festlegen bevor ich welche finden kann.",
            "Du willst Geräte in Räumen bedienen obwohl ich gar keine Räume habe. Das klappt nicht."
        ],
        "err_lowscoreroom"=>[
            "Den Raum %ROOM% konnte ich nicht finden. ",
            "Mit dem Raum %ROOM% kann ich nichts anfangen",
            "Den Raum %ROOM% gibt es nicht."
        ],
        "err_nodevice"=>[
            "Du hast keine Geräte benannt. Gib deinen Geräten einen Alias damit ich sie finden kann.",
            "Du hast keinem Gerät einen Namen zugeordnet. Das solltest du vorher machen."
        ],
        "err_nodevicematch"=>[
            "Ich konnte kein Gerät in deinem Befehl erkennen."
        ],
        "err_lowscoredevice"=>[
            "Das Gerät %ALIAS% konnte ich nicht finden. ",
            "Ich finde das Gerät %ALIAS% nicht. Sicher das so eines existiert?"
        ],
        "err_singlemultidevice"=>[
            "Ich finde zuviele Geräte die den Namen %ALIAS% haben obwohl du nur eins ansteuern möchtest. Nimm alle oder nenn mir einen Raum dazu.",
            "Von %ALIAS% habe ich mehrer gefunden, soll allerdings nur eines ansteuern.",
            "%ALIAS% gibt es häufiger. Sei genauer wenn du %ALIAS% schalten möchtest."
        ],
        "err_feature"=>[
            "Das Feature %FEATURE% im Attribut Feature ist nicht aktiviert. ",
            "Entschuldige aber dafür musst du im Attribut Feature das Feature %FEATURE% aktivieren.",
            "Aktivier dafür das Feature %FEATURE% im Attribut Feature."
        ],
        "err_deviceroommatchfail"=>[
            "Das Gerät %ALIAS% scheint es in dem von dir gewünschten Raum nicht zu geben."    
        ],
        "err_battcome_ok_low"=>[
            "Der Batteriestatus von %NAME% ist nicht in Ordnung.",
            "%NAME% meldet niedrigen Batteriestatus.",
        ],
        "err_battgo_ok_low"=>[
            "Der Batteriestatus von %NAME% ist wieder in Ordnung.",
            "%NAME% meldet die Batterie wieder ok.",
        ],
        "err_battcome_int"=>[
            "Der Batteriestatus von %NAME% liegt unter 10.",
        ],
        "err_battgo_int"=>[
            "Der Batteriestatus von %NAME% liegt wieder über 10.",
        ],,
        "err_changing_dev_name"=>[
            "Das Gerät %DEV1% wurde in %DEV2% umbenannt. Ich habe mir das gemerkt.",
            "%DEV1% zu %DEV2%. Check",
        ],
        "err_restrictedmapping"=>[
            "Der Befehl ist nicht für das Gerät vorgesehen."    
        ],
        "err_restrictedmapping_alias"=>[
            "Der Befehl ist nicht für das Gerät %ALIAS% vorgesehen."    
        ],
        "err_restrictedmapping_alias_room"=>[
            "Der Befehl ist nicht für das Gerät %ALIAS% %ROOM% vorgesehen."    
        ]
    }
);
my %teerkobuild_template = (
        "stime" => "",
        "etime" => "",
        "ocommand" => "",
        "pcommand" => "",
        "hashdata" => {
            "name" => "",
        },
        "replydata" => {
            "to" => "",
            "device" => "",
            "supply1" => "",
            "supply2" => "",
            "combined" => ""
        },
        "data" => {
            "substrings" => [],
            "tokens" => [],
            "responses"=>[],
            "fhemcommands"=>[],
        },
    );

my %TEERKO_sets = (
    "TextCommand"                => "textField",
    "UpdateLists"                => "noArg",
    "AMADAnswer"                 => "multiple,-msg-,-tts-",
    "OwnAnswer"                 => "textField",
    "TelegramAnswer"                 => "textField",
    "ReadUserFile"               => "textField",
    #"TelegramAnswer"            => "text,voice,sonos",
);
my %TEERKO_gets = (
    "Information"                => "all,rooms,devices"
);
sub TEERKO_Initialize($) {
    my ($hash) = @_;

    $hash->{DefFn}    = 'TEERKO_Define';
    $hash->{UndefFn}  = 'TEERKO_Undef';
    $hash->{SetFn}    = 'TEERKO_Set';
    $hash->{GetFn}    = 'TEERKO_Get';
    $hash->{AttrFn}   = 'TEERKO_Attr';
    $hash->{NotifyFn} = 'TEERKO_Notify';
    
    addToAttrList("TEERKOAlias:textField");
    addToAttrList("TEERKORoom:textField");
    addToAttrList("TEERKOExpert:textField");
    
    TEERKO_buildlist($hash);
    $hash->{AttrList} =TEERKO_buildattr($hash);
    $hash->{VERSION}      = $modulversion;
}

sub TEERKO_Define($$) {
    my ($hash, $def) = @_;
    my @param = split('[ \t]+', $def);
    
    $hash->{VERSIONMODUL} = $modulversion;
    $hash->{NAME}  = $param[0];
    return undef;
}

sub TEERKO_Undef($$) {
    my ($hash, $arg) = @_; 
    RemoveInternalTimer($hash);
    return undef;
}

sub TEERKO_Get($@) {
    my ($hash, @param) = @_;
    my $name = shift @param;
    my $opt = shift @param;
    my $value = join(" ", @param);
    
    if (!exists($TEERKO_gets{$opt}))  {
        my @cList;
        foreach my $k (keys %TEERKO_gets) {
            my $opts = undef;
            $opts = $TEERKO_gets{$k};

            if (defined($opts)) {
                push(@cList,$k . ':' . $opts);
            } else {
                push (@cList,$k);
            }
        } # end foreach

        return "Teerko_Get: Unknown argument $opt, choose one of " . join(" ", @cList);
    } # error unknown opt handling
    if($opt =~ /^information$/i){
        my $htmlresponse = TEERKO_HtmlTeerko();
        if($value =~ /^(all|devices)$/i){
            $htmlresponse .= TEERKO_HtmlDevices();
        }
        if($value =~ /^(all|rooms)$/i){
            $htmlresponse .= TEERKO_HtmlRooms();
        }
        return $htmlresponse;
    }
    return undef;
    
}
    
sub TEERKO_Set($@) {
    my ($hash, @param) = @_;
    my $name = shift @param;
    my $opt = shift @param;
    my $value = join(" ", @param);
    
    if (!exists($TEERKO_sets{$opt}))  {
        my @cList;
        TEERKO_buildlist($hash, "all");
        foreach my $k (keys %TEERKO_sets) {
            my $opts = undef;
            $opts = $TEERKO_sets{$k};

            if (defined($opts)) {
                push(@cList,$k . ':' . $opts);
            } else {
                push (@cList,$k);
            }
        } # end foreach

        return "Teerko_Set: Unknown argument $opt, choose one of " . join(" ", @cList);
    } # error unknown opt handling
    if($opt =~ /^textcommand$/i){
        readingsSingleUpdate( $hash, "command", $value, 1 );
        my %teerkobuild = %{ dclone \%teerkobuild_template };
        $teerkobuild{replydata}{to}="own";
        $teerkobuild{hashdata}=$hash;
        $teerkobuild{ocommand}=$value;
        TEERKO_CheckCommand(%teerkobuild);
    }
    if($opt =~ /^updatelists/i){
        TEERKO_buildlist($hash);
    }
    if($opt =~ /^ReadUserFile$/i){
        $value eq "" ? TEERKO_ReadUserDef($hash, AttrVal($hash->{NAME},"TEERKOUserDefFile","")) : TEERKO_ReadUserDef($hash, $value);
    }
    if($opt =~ /^(telegram|own|amad)answer/i){
        readingsSingleUpdate( $hash, $opt, $value, 1 );
    }
    if($opt =~ /^externalresponse/i){
        readingsSingleUpdate( $hash, $opt, $value, 1 );
    }


    return undef;
}

sub TEERKO_Attr(@) {
    my ( $cmd, $name, $attrName, $attrValue ) = @_;
    my $hash = $defs{$name};
    
    return undef;

}

sub TEERKO_Notify($$){
    my ($ownhash, $devhash) = @_;
    my $ownName = $ownhash->{NAME}; # own name / hash
    my $devName = $devhash->{NAME}; # dev name / hash

    return "" if(IsDisabled($ownName)); # Return without any further action if the module is disabled
    
    my $events = deviceEvents($devhash,1);
    return if( !$events );
    if($devhash->{TYPE} =~ /global/i){
        foreach my $event (@{$events}) {
            $event = "" if(!defined($event));
            if($event =~ /INITIALIZED/){
                $ownhash->{globalinit}="1";
                InternalTimer(gettimeofday() + 1, "TEERKO_buildlist", $ownhash);
            }
            last if(!InternalVal($ownName,"globalinit","0"));
            if($event =~ /^DEFINED|^DELETED/){
                InternalTimer(gettimeofday() + 1, "TEERKO_buildlist", $ownhash);
            }
            if($event =~ /^RENAMED/i){
                my @eventsparts = split(" ",$event);
                my @allowedtocontrols = split(",",AttrVal($ownName,"TEERKOAllowedToControl",""));
                if(TEERKO_ValueInArray($eventsparts[1],@allowedtocontrols)){
                    foreach my $allowedtocontrol (@allowedtocontrols){
                        if($allowedtocontrol eq $eventsparts[1]){
                            $allowedtocontrol = $eventsparts[2] ;
                            last;
                        }
                    }
                    if(AttrVal($ownName,"TEERKOFeatures","")=~/informFHEMActions|\-Alle\-/i){
                        my %teerkobuild = %{ dclone \%teerkobuild_template };
                        $teerkobuild{replydata}{to}="all";
                        $teerkobuild{hashdata}=$ownhash;
                        my $response = $TEERKO_brain{"responsetext"}{"err_changing_dev_name"}[rand @{$TEERKO_brain{"responsetext"}{"err_changing_dev_name"}}];
                        $response =~ s/%DEV1%/${eventsparts[1]}/gi;
                        $response =~ s/%DEV2%/${eventsparts[2]}/gi;
                        push(@{$teerkobuild{data}{responses}},$response);
                        TEERKO_Responder(%teerkobuild);
                    }
                    fhem("attr $ownName TEERKOAllowedToControl ". join(",", @allowedtocontrols))
                }
                InternalTimer(gettimeofday() + 1, "TEERKO_buildlist", $ownhash);
            }
        }
    }
    if(($devhash->{TYPE} =~ /telegrambot/i && AttrVal($ownName,"TEERKOTelegramDevice","") =~/${devName}/i) || $devhash->{TYPE} =~ /amad/i || ($devhash->{TYPE} =~ /sonosplayer/i)){
        foreach my $event (@{$events}) {
            $event = "" if(!defined($event));
            if($devhash->{TYPE} =~ /telegrambot/i){
                my $peerid=AttrVal($ownName,"TEERKOTelegramPeerId","xxxxxxxx");
                $peerid =~ s/,/\|/g;
                if($event =~ /msgPeerId.*($peerid)/){
                    $ownhash->{".TELEGRAMmsgChat"} = ReadingsVal($devName, "msgChat", "");
                    $ownhash->{".TELEGRAMmsgFileId"} = ReadingsVal($devName, "msgFileId", "");
                    $ownhash->{".TELEGRAMmsgId"} = ReadingsVal($devName, "msgId", "");
                    $ownhash->{".TELEGRAMmsgPeer"} = ReadingsVal($devName, "msgPeer", "");
                    $ownhash->{".TELEGRAMmsgPeerId"} = ReadingsVal($devName, "msgPeerId", "");
                    $ownhash->{".TELEGRAMmsgReplyMsgId"} = ReadingsVal($devName, "msgReplyMsgId", "");
                    $ownhash->{".TELEGRAMmsgText"} = ReadingsVal($devName, "msgText", "");
                    readingsSingleUpdate( $ownhash, "command", InternalVal($ownName,".TELEGRAMmsgText",""), 1 );
                    my %teerkobuild = %{ dclone \%teerkobuild_template };
                    $teerkobuild{replydata}{to}="telegram";
                    $teerkobuild{replydata}{device}=$devName;
                    $teerkobuild{replydata}{supply1}=InternalVal($ownName,".TELEGRAMmsgPeerId","");
                    $teerkobuild{hashdata}=$ownhash;
                    $teerkobuild{ocommand}=InternalVal($ownName,".TELEGRAMmsgText","");
                    TEERKO_CheckCommand(%teerkobuild);
                }
            }
            if($devhash->{TYPE} =~ /amad/i){
                my $amadid=AttrVal($ownName,"TEERKOAMADDevice","xxxxxxxxxxxxxx");
                $amadid = join("|",devspec2array("TYPE=AMADDevice"))if(AttrVal($ownName,"TEERKOAMADDevice","") =~ /-Alle-/i);
                $amadid =~ s/,/\|/g;
                if($event =~ /receiveVoiceDevice.*(${amadid})/i){
                    $ownhash->{".AMADreceiveVoiceCommand"} = ReadingsVal($devName, "receiveVoiceCommand", "");
                    $ownhash->{".AMADreceiveVoiceDevice"} = ReadingsVal($devName, "receiveVoiceDevice", "");
                    readingsSingleUpdate( $ownhash, "command", InternalVal($ownName,".AMADreceiveVoiceCommand",""), 1 );
                    my %teerkobuild = %{ dclone \%teerkobuild_template };
                    $teerkobuild{replydata}{to}="amad";
                    $teerkobuild{replydata}{device}=InternalVal($ownName,".AMADreceiveVoiceDevice","");
                    $teerkobuild{hashdata}=$ownhash;
                    $teerkobuild{ocommand}=InternalVal($ownName,".AMADreceiveVoiceCommand","");
                    TEERKO_CheckCommand(%teerkobuild);
                }
            }
            if($devhash->{TYPE} =~ /sonosplayer/i){
                if($event =~ /LastActionResult.*getradios: (.*)/i){
                    readingsSingleUpdate( $ownhash, ".sonos_radios", $1, 0 );
                }
                if($event =~ /LastActionResult.*getplaylists: (.*)/i){
                    readingsSingleUpdate( $ownhash, ".sonos_playlists", $1, 0 );
                }
                if($event =~ /LastActionResult.*getfavourites: (.*)/i){
                    readingsSingleUpdate( $ownhash, ".sonos_favourites", $1, 0 );
                }
            }
        }
    }else{
        foreach my $event (@{$events}) {
            $event = "" if(!defined($event));
            if($event =~ /.*battery:.*/i && AttrVal($ownName,"TEERKOFeatures","")=~/informlowBattery|\-Alle\-/i){
                if($event =~ /(\d+)/){
                    my $batval = $1;
                    if($batval<=10 && ReadingsVal($ownName,"." . $devName . "_battery","") !~ m /low/){
                        my %teerkobuild = %{ dclone \%teerkobuild_template };
                        $teerkobuild{replydata}{to}="all";
                        $teerkobuild{hashdata}=$ownhash;
                        my $response = $TEERKO_brain{"responsetext"}{"err_battcome_int"}[rand @{$TEERKO_brain{"responsetext"}{"err_battcome_int"}}];
                        $response =~ s/%NAME%/${devName}/gi;
                        push(@{$teerkobuild{data}{responses}},$response);
                        TEERKO_Responder(%teerkobuild);
                        
                        readingsSingleUpdate( $ownhash, "." . $devName . "_battery", "low", 0 );
                        readingsSingleUpdate( $ownhash, $devName . "_battery", "low", 0 );
                    }elsif($batval>10 && ReadingsVal($ownName,"." . $devName . "_battery","") !~ m /ok/){
                        my %teerkobuild = %{ dclone \%teerkobuild_template };
                        $teerkobuild{replydata}{to}="all";
                        $teerkobuild{hashdata}=$ownhash;
                        my $response = $TEERKO_brain{"responsetext"}{"err_battgo_int"}[rand @{$TEERKO_brain{"responsetext"}{"err_battgo_int"}}];
                        $response =~ s/%NAME%/${devName}/gi;
                        push(@{$teerkobuild{data}{responses}},$response);
                        TEERKO_Responder(%teerkobuild);
                        
                        readingsSingleUpdate( $ownhash, "." . $devName . "_battery", "ok", 0 );
                        readingsSingleUpdate( $ownhash, $devName . "_battery", "ok", 0 );
                    }
                }else{
                    if($event !~ m/ok/ && ReadingsVal($ownName,"." . $devName . "_battery","") !~ m /low/) {
                        my %teerkobuild = %{ dclone \%teerkobuild_template };
                        $teerkobuild{replydata}{to}="all";
                        $teerkobuild{hashdata}=$ownhash;
                        my $response = $TEERKO_brain{"responsetext"}{"err_battcome_ok_low"}[rand @{$TEERKO_brain{"responsetext"}{"err_battcome_ok_low"}}];
                        $response =~ s/%NAME%/${devName}/gi;
                        push(@{$teerkobuild{data}{responses}},$response);
                        TEERKO_Responder(%teerkobuild);
                        
                        readingsSingleUpdate( $ownhash, "." . $devName . "_battery", "low", 0 );
                        readingsSingleUpdate( $ownhash, $devName . "_battery", "low", 0 );
                    }elsif($event =~ m/ok/ && ReadingsVal($ownName,"." . $devName . "_battery","") !~ m /ok/){
                        my %teerkobuild = %{ dclone \%teerkobuild_template };
                        $teerkobuild{replydata}{to}="all";
                        $teerkobuild{hashdata}=$ownhash;
                        my $response = $TEERKO_brain{"responsetext"}{"err_battgo_ok_low"}[rand @{$TEERKO_brain{"responsetext"}{"err_battgo_ok_low"}}];
                        $response =~ s/%NAME%/${devName}/gi;
                        push(@{$teerkobuild{data}{responses}},$response);
                        TEERKO_Responder(%teerkobuild);
                        
                        readingsSingleUpdate( $ownhash, "." . $devName . "_battery", "ok", 0 );
                        readingsSingleUpdate( $ownhash, $devName . "_battery", "ok", 0 );
                    }
                }
            }
        }
    }
}

sub TEERKO_ReadUserDef($$){
    my ($hash, $file) = @_;
    if (-e $file){
        local $/ = undef;
        open FILE, $file or return "Couldn't open file: $!";
        binmode FILE;
        my $string = <FILE>;
        close FILE;
        readingsSingleUpdate( $hash, ".usercommandfile", $string, 0 );
        readingsSingleUpdate( $hash, "state", "Datei wurde eingelesen", 1 );
        Log3 $hash->{NAME}, 5, $hash->{NAME} . ": Read User Def Command File $string";
        my $countusercommands =0;
        fhem("deletereading " . $hash->{NAME} . " userdefinedcommand.*");
        while ($string =~ /(?s)\[command\](.[^\[]*)/g) {
            $countusercommands++;
            my $userpart = $1;
            ($userpart =~ /^activ=.*0.*$/im) ? (readingsSingleUpdate( $hash, "userdefinedcommand" . $countusercommands . "_active", "0", 0 )) : (readingsSingleUpdate( $hash, "userdefinedcommand" . $countusercommands . "_active", "1", 0 ));
            ($userpart =~ /^in=(.+)$/im) ? (readingsSingleUpdate( $hash, "userdefinedcommand" . $countusercommands . "_in", "$1", 0 )) : ();
        }
        readingsSingleUpdate( $hash, "usercommands", $countusercommands, 1 );
    }else{
        readingsSingleUpdate( $hash, "state", "Error: File existiert nicht", 1 );
    }
    
}

sub TEERKO_CheckUserCommand{
    my (%teerkobuild) = @_;
    Log3 $teerkobuild{hashdata}{NAME}, 4, $teerkobuild{hashdata}{NAME} . ": Search Userdefined Commands in Substrings";
    
    my $countusercommands =0;
    my $string=ReadingsVal($teerkobuild{hashdata}{NAME},".usercommandfile","");
    while ($string =~ /(?s)\[command\](.[^\[]*)/g) {
        Log3 $teerkobuild{hashdata}{NAME}, 5, $teerkobuild{hashdata}{NAME} . ": Check User Def Command " . $countusercommands++;
        my $userpart = $1;
        my $userin;
        my $userout;
        unless($userpart =~ /^activ=.*0.*$/m){
            if ($userpart =~ /^in=(.+)$/im) {
                $userin = $1;
                $userin =~ s/^\s+|\s+$//g;
                my $regex = eval { qr/$userin/ };
                unless($@){
                    for my $substr(@{$teerkobuild{data}{substrings}}){
                        my $comparestring ="";
                        for my $token(@{$$substr{tokens}}){
                            $comparestring .= $$token{token} . " "
                        }
                        if(my @findings = $comparestring =~ /${userin}/i ){
                            $$substr{usercommand}=1;
                            while ($userpart =~ /^fhem=(.+)/gmi){
                                my $fhemcommand=$1;
                                $fhemcommand =~ s/^\s+|\s+$//g;
                                while ($fhemcommand =~ /\%(\d+)\%/gmi){
                                    my $findingsnumber = $1;
                                    my $findingsvalue = "UNKNOWN";
                                    $findingsvalue = $findings[$findingsnumber] if(exists($findings[$findingsnumber]));
                                    $fhemcommand =~ s/\%${findingsnumber}\%/${findingsvalue}/gi;
                                }
                                Log3 $teerkobuild{hashdata}{NAME}, 5, $teerkobuild{hashdata}{NAME} . ": Check User Def Command $fhemcommand";
                                push(@{$$substr{fhemcommands}}, $fhemcommand);
                            }
                            Log3 $teerkobuild{hashdata}{NAME}, 5, $teerkobuild{hashdata}{NAME} . ": User Def Command $countusercommands MATCH";
                            ($userpart =~ /^out=(.*)$/im) ? $userout = $1 : ($userout = "Ok");
                            while ($userout =~ /\%(\d+)\%/gmi){
                                my $findingsnumber = $1;
                                my $findingsvalue = "UNKNOWN";
                                $findingsvalue = $findings[$findingsnumber] if(exists($findings[$findingsnumber]));
                                $userout =~ s/\%${findingsnumber}\%/${findingsvalue}/gi;
                            }
                            while($userout =~ /\%([^\%]*?):([^\%]*?):([^\%]*?)\%/){
                                my $device = $1;
                                my $reading = $2;
                                my $replace = $3;
                                my $devicereading = ReadingsVal($device,$reading,"");
                                while($replace =~ /([^,;&]*)=([^,;&]*)/g){
                                    my $search = $1;
                                    my $replacewith = $2;
                                    $devicereading =~ s/\b${search}\b/\b${replacewith}\b/;
                                }
                                $userout =~ s/\%([^\%]*?):([^\%]*?):([^\%]*?)\%/\!${devicereading}\!/;
                            }
                            while($userout =~ /\%([^\%]*?):([^\%]*?)\%/){
                                my $device = $1;
                                my $reading = $2;
                                my $devicereading = ReadingsVal($device,$reading,"");
                                $userout =~ s/\%([^\%]*?):([^\%]*?)\%/\!${devicereading}\!/;
                            }
                            while($userout =~ /\%([^\%]*?)\%/){
                                my $device = $1;
                                my $devicereading = ReadingsVal($device,"state","");
                                $userout =~ s/\%([^\%]*?)\%/\!${devicereading}\!/;
                            }
                            Log3 $teerkobuild{hashdata}{NAME}, 5, $teerkobuild{hashdata}{NAME} . ": User Def Out $userout";
                            push(@{$$substr{responses}}, $userout);
                        }else{
                            Log3 $teerkobuild{hashdata}{NAME}, 5, $teerkobuild{hashdata}{NAME} . ": User Def Command $countusercommands KEIN MATCH";
                        }
                    }
                }else{
                    Log3 $teerkobuild{hashdata}{NAME}, 5, $teerkobuild{hashdata}{NAME} . ": ERROR -> IN Regex ist fehlerhaft";
                }
            }else{
                Log3 $teerkobuild{hashdata}{NAME}, 5, $teerkobuild{hashdata}{NAME} . ": ERROR -> Kein IN gefunden";
            }
        }
    }
    
    return %teerkobuild;
}
    
sub TEERKO_CheckCommand{
    my (%teerkobuild) = @_;
    Log3 $teerkobuild{hashdata}{NAME}, 3, $teerkobuild{hashdata}{NAME} . ": Got something. Lets see what it is. ";
    $teerkobuild{stime} = gettimeofday();
    $teerkobuild{pcommand} = $teerkobuild{ocommand};
    $teerkobuild{replydata}{combined} = $teerkobuild{replydata}{to}."_".$teerkobuild{replydata}{device}."_".$teerkobuild{replydata}{supply1}."_".$teerkobuild{replydata}{supply2};
    
    $teerkobuild{hashdata}{"MODE_".$teerkobuild{replydata}{combined}} = 0 if(!exists($teerkobuild{hashdata}{"MODE_".$teerkobuild{replydata}{combined}}));
    
    my @hotwords = split(",",AttrVal($teerkobuild{hashdata}{NAME},"TEERKOHotword",""));
    if(scalar @hotwords >0){
        foreach my $hotword(@hotwords){
            return if($teerkobuild{ocommand}!~/\b${hotword}\b/i);
        }
    }
    
    # Command Preperations
    %teerkobuild = TEERKO_CommandPreperations(%teerkobuild);

    # Tokenizing
    %teerkobuild = TEERKO_Tokenizing(%teerkobuild);
    
    # Tokenizing Room Device
    %teerkobuild = TEERKO_TokenizingRoomDevice(%teerkobuild);
    
    # Sentence limit
    %teerkobuild = TEERKO_Substring(%teerkobuild);
    
    # Finding User Commands
    %teerkobuild = TEERKO_CheckUserCommand(%teerkobuild) if(AttrVal($teerkobuild{hashdata}{NAME},"TEERKOFeatures","")=~/userdefinedcommands|\-Alle\-/i);
    
    # Finding All possible Actions
    %teerkobuild = TEERKO_FindActions(%teerkobuild);
    
    # ActionWorker On Existing Actions
    %teerkobuild = TEERKO_ActionWorker(%teerkobuild);
    
    # Execute all found fhem commands
    %teerkobuild = TEERKO_FHEMExecuter(%teerkobuild);
    
    #Build the Answer String and send to User and external Devices
    %teerkobuild = TEERKO_Responder(%teerkobuild);
    
    Log3 $teerkobuild{hashdata}{NAME}, 5, $teerkobuild{hashdata}{NAME} . ": Show comlete Array for all people who are interested";
    Log3 $teerkobuild{hashdata}{NAME}, 5, $teerkobuild{hashdata}{NAME} . ": " . Dumper(\%teerkobuild);
    
    #Action
    #Log3 $hash->{NAME}, 4, $hash->{NAME} . ": " . Dumper(\@substrings);
    
    Log3 $teerkobuild{hashdata}{NAME}, 3, $teerkobuild{hashdata}{NAME} . ": Got it. Completed with analysing, tokenizing, splitting, excecuting, responding.YEAH.";
    
    return;
}

sub TEERKO_ValueInArray{
    my ($value, @array) = @_;
    foreach (@array) {
        return 1 if ($_ =~ /^${value}$/i);
    }
    return 0;
}

sub TEERKO_DelDouble{ 
    my @array = @_;
    for(my $i=0;$i<scalar @array;$i++){
        for(my $j=scalar @array-1;$j>$i;$j--){
            splice (@array, $j, 1) if($array[$i] =~ s/!//gr eq $array[$j] =~ s/!//gr);
        }
    }
    return @array;
}

sub TEERKO_QgramScore{
    my ($string1, $string2, $cmode) = @_;
    $cmode = 2 if(!defined($cmode));
    my $ngramlength = 2;
    my $ngramfiller = "x" x ($ngramlength-1);
    
    $string1 = $ngramfiller . $string1 . $ngramfiller;
    $string2 = $ngramfiller . $string2 . $ngramfiller;
    
    $string1 =~ s/ä/ae/g;
    $string1 =~ s/ö/oe/g;
    $string1 =~ s/ü/ue/g;
    $string1 =~ s/Ä/Ae/g;
    $string1 =~ s/Ö/Oe/g;
    $string1 =~ s/Ü/Ue/g;
    $string1 =~ s/ß/ss/g;
    
    $string2 =~ s/ä/ae/g;
    $string2 =~ s/ö/oe/g;
    $string2 =~ s/ü/ue/g;
    $string2 =~ s/Ä/Ae/g;
    $string2 =~ s/Ö/Oe/g;
    $string2 =~ s/Ü/Ue/g;
    $string2 =~ s/ß/ss/g;
    
    $string1 =~ tr/a-zA-Z0-9//dc;
    $string2 =~ tr/a-zA-Z0-9//dc;
    
    $string1 =~ uc($string1);
    $string2 =~ uc($string2);
    
    my $qlen_string1 = length($string1) - 1;
    my $qlen_string2 = length($string2) - 1;
    my $qlen_max = ($qlen_string1, $qlen_string2)[$qlen_string1 < $qlen_string2];
    
    my $pct_divisor = $qlen_string1;
    $pct_divisor = $qlen_max if ($cmode == 2);

    my $avg_divisor = 1;
    $avg_divisor = 2 if ($cmode == 2);
    
    my $score = 0;
    my $position = 0;
    if($cmode == 1 || $cmode == 2){
        for(my $i = 0;$i < $qlen_string1;$i++){
            my $findme = substr($string1,$i,$ngramlength);
            my $instring = substr($string2,$position,$qlen_string2+1);
            if($instring =~ /(${findme})/ig){
                $score++;
                $position = (pos($instring) - length $1) + 1;
            }
        }
    }
    $position = 0;
    if($cmode == 2){
        for(my $i = 0;$i < $qlen_string2;$i++){
            my $findme = substr($string2,$i,$ngramlength);
            my $instring = substr($string1,$position,$qlen_string1);
            if($instring =~ /(${findme})/ig){
                $score++;
                $position = (pos($instring) - length $1) + 1;
            }
        }
    }
    $score = $score / $avg_divisor;

    my $score_pct = $score / $pct_divisor;

    return $score_pct;
}

sub TEERKO_HtmlRooms{
    my $web = "<h1>Teerko Rooms</h1><hr><p>Auflistung aller gefundenen Teerko Rooms</p><table border=1 CELLPADDING=10 style='min-width:800px;'><tr><th>TEERKORoom</th><th>Devices</th></tr>";
    my @teerkorooms =devspec2array("TEERKORoom=.+");
    my @rooms=();
    for my $teerkoroom (@teerkorooms){
        my @temprooms = split(",",AttrVal($teerkoroom,"TEERKORoom",""));
        for my $temproom (@temprooms){
            unless(TEERKO_ValueInArray($temproom, @rooms)){
                push(@rooms,$temproom);
            }
        }
    }
    for my $room(sort @rooms){
        my @devs =devspec2array("TEERKORoom=.*" . $room . ".*");
        @devs = sort @devs;
        for(my $i=0;$i<scalar @devs;$i++){
            $devs[$i]="<a href='fhem?detail=" . $devs[$i] . "'>" . $devs[$i] . "</a>";
        }
        $web .= "<tr><td id='TEERKO_room_" . $room . "'>" . $room . "</td><td>" . join("<br>", @devs) . "</td></tr>";
    }
    $web .= "</table>";
    return $web;
}

sub TEERKO_HtmlTeerko{
    my @teerkodevices =devspec2array("TYPE=TEERKO");
    my $web = "<h1>Teerko Devices</h1><hr><p>Auflistung aller TEERKO Devices</p><table border=1 CELLPADDING=10 style='min-width:800px;'><tr><th>Device</th><th>Sonos Integration</th></tr>";
    for my $teerkodevice (@teerkodevices){
        $web .= "<tr><td><a href='fhem?detail=" . $teerkodevice . "'>" . $teerkodevice . "</a></td>";
        $web .= "<td";
        $web .= " bgcolor='green'" if (int(AttrVal($teerkodevice,"SonosIntegration","0")));
        $web .= ">" . AttrVal($teerkodevice,"SonosIntegration","0") . "</td></tr>";
    }
    $web .= "</table>";
}

sub TEERKO_HtmlDevices{
    my $web = "<h1>Teerko Touched Devices</h1><hr><p>Auflistung aller gefundenen Geräte die entweder TEERKOAlias oder TEERKORoom gesetzt haben</p><table border=1 CELLPADDING=10 style='min-width:800px;'><tr><th>Device</th><th>Teerko Aliase</th><th>Teerko Rooms</th><th>Teerko Control</th></tr>";
    my @teerkodevices =devspec2array("TEERKOAlias=.+");
    my @teerkodevices_room =devspec2array("TEERKORoom=.+");
    for my $teerkodevice (@teerkodevices_room){
        unless(TEERKO_ValueInArray($teerkodevice, @teerkodevices)){
            push(@teerkodevices,$teerkodevice);
        }
    }
    @teerkodevices = sort @teerkodevices;
    for my $teerkodevice (@teerkodevices){
        my @temprooms = split(",",AttrVal($teerkodevice,"TEERKORoom",""));
        @temprooms = sort @temprooms;
        for(my $i=0;$i<scalar @temprooms;$i++){
            $temprooms[$i]="<a href='#TEERKO_room_" . $temprooms[$i] . "'>" . $temprooms[$i] . "</a>";
        }
        my @tempaliase = split(",",AttrVal($teerkodevice,"TEERKOAlias",""));
        $web .= "<tr><td><a href='fhem?detail=" . $teerkodevice . "'>" . $teerkodevice . "</a><br><sup>(TYPE: " . InternalVal($teerkodevice,"TYPE","na") . ")</sup></td><td>" . join("<br>", @tempaliase) . "</td><td>" . join("<br>", @temprooms) . "</td><td>" . AttrVal($teerkodevice,"TEERKOControl","0") . "</td></tr>";
    }
    $web .= "</table>";
    return $web;
}

sub TEERKO_buildattr{
    my ($hash) = @_;
    my @alldevices =("-Alle-", devspec2array("TEMPORARY!=1:FILTER=TYPE!=(FileLog|FHEMWEB|Global|eventTypes|telnet|autocreate)"));
    @alldevices = sort @alldevices;
    my @telegramdevices =devspec2array("TYPE=TelegramBot");
    @telegramdevices = sort @telegramdevices;
    my @amaddevices =("-Alle-", devspec2array("TYPE=AMADDevice"));
    #my @amaddevices =devspec2array("TYPE=AMADDevice");
    @amaddevices = sort @amaddevices;
    my @telegramcontacts=();
    for my $telegramdevice (@telegramdevices){
        for my $telegramcontact (split(" ", ReadingsVal($telegramdevice,"Contacts",""))){
            push(@telegramcontacts,$1) if($telegramcontact =~ /^(\d+|-\d+)/);
        }
    }
    @telegramcontacts = sort @telegramcontacts;
    
    return
       "TEERKOTelegramDevice:multiple-strict,".join(",",@telegramdevices)." "
      ."TEERKOAllowedToControl:multiple-strict,".join(",",@alldevices)." "
      ."TEERKOFeatures:multiple-strict,-Alle-,BasicControl,InformLowBattery,UserDefinedCommands,InformFHEMActions "
      ."TEERKOTelegramPeerId:multiple-strict,".join(",",@telegramcontacts)." "
      ."TEERKOAMADDevice:multiple-strict,".join(",",@amaddevices)." "
      ."TEERKOHotword:textField "
      ."TEERKOUserDefFile:textField "
      #."CalenderDevices "
    . $readingFnAttributes;
    return;
}

sub TEERKO_buildlist{
    my ($hash) = @_;
    
    $modules{$hash->{TYPE}}{AttrList}= TEERKO_buildattr($hash);

    #$TEERKO_sets{"ExternalResponse"} = "multiple-strict," . join(",",devspec2array("TYPE=(SONOSPLAYER|Text2Speech|KODI|Pushover)"));


    return;
}

sub TEERKO_SearchISTClima{
    my ($hash, $device, $information) = @_;
    my @return=(0,0);
    if($information==1){
        Log3 $hash->{NAME}, 5, "$hash->{NAME}: Suche Temperaturinformationen im Device -> $device";
        if(defined(ReadingsVal($device,"measured-temperature",undef))){
            @return=(1,1*ReadingsVal($device,"measured-temperature",undef));
            Log3 $hash->{NAME}, 5, "$hash->{NAME}: +-> Gefunden";
            return @return;
        }
        if(defined(ReadingsVal($device,"measured-temp",undef))){
            @return=(1,1*ReadingsVal($device,"measured-temp",undef));
            Log3 $hash->{NAME}, 5, "$hash->{NAME}: +-> Gefunden";
            return @return;
        }
        if(defined(ReadingsVal($device,"ist-temp",undef))){
            @return=(1,1*ReadingsVal($device,"ist-temp",undef));
            Log3 $hash->{NAME}, 5, "$hash->{NAME}: +-> Gefunden";
            return @return;
        }
        if(defined(ReadingsVal($device,"ist-temperature",undef))){
            @return=(1,1*ReadingsVal($device,"ist-temperature",undef));
            Log3 $hash->{NAME}, 5, "$hash->{NAME}: +-> Gefunden";
            return @return;
        }
        if(defined(ReadingsVal($device,"temperature",undef))){
            @return=(1,1*ReadingsVal($device,"temperature",undef));
            Log3 $hash->{NAME}, 5, "$hash->{NAME}: +-> Gefunden";
            return @return;
        }
        Log3 $hash->{NAME}, 5, "$hash->{NAME}: +-> Nicht vorhanden";
    }elsif($information==2){
        Log3 $hash->{NAME}, 5, "$hash->{NAME}: Suche Luftfeuchtigkeit im Device -> $device";
        if(defined(ReadingsVal($device,"humidity",undef))){
            @return=(1,1*ReadingsVal($device,"humidity",undef));
            Log3 $hash->{NAME}, 5, "$hash->{NAME}: +-> Gefunden";
            return @return;
        }
        Log3 $hash->{NAME}, 5, "$hash->{NAME}: +-> Nicht vorhanden";
    }
    return @return;
}

sub TEERKO_ActionWorker{
    my (%teerkobuild) = @_;
    Log3 $teerkobuild{hashdata}{NAME}, 4, $teerkobuild{hashdata}{NAME} . ": Create All Actions Responses, if exists";

    for(my $i=0;$i<scalar @{$teerkobuild{data}{substrings}};$i++){
        %teerkobuild = $teerkobuild{data}{substrings}[$i]{'action'}{'function'}($i, %teerkobuild)if(!$teerkobuild{data}{substrings}[$i]{'usercommand'});
    }
    
    return %teerkobuild;
}

sub TEERKO_Responder{
    my (%teerkobuild) = @_;
    Log3 $teerkobuild{hashdata}{NAME}, 4, $teerkobuild{hashdata}{NAME} . ": Responding to Requesting Device";
    my $resonding ="";
    Log3 $teerkobuild{hashdata}{NAME}, 5, $teerkobuild{hashdata}{NAME} . ": +--> Building Response Sentence";
    for(my $i=0;$i<scalar @{$teerkobuild{data}{responses}};$i++){
        $resonding .= ucfirst($teerkobuild{data}{responses}[$i]) . " ";
        Log3 $teerkobuild{hashdata}{NAME}, 5, $teerkobuild{hashdata}{NAME} . ": +-->+--> Adding: " . $teerkobuild{data}{responses}[$i];
    }
    $resonding .= " \n";
    for(my $j=0;$j<scalar @{$teerkobuild{data}{substrings}};$j++){
        for(my $i=0;$i<scalar @{$teerkobuild{data}{substrings}[$j]{responses}};$i++){
            $resonding .= ucfirst($teerkobuild{data}{substrings}[$j]{responses}[$i]) . " ";
        }
        $resonding .= " \n";
    }
    $resonding =~ s/^(\s+|\n+)|(\s+|\n+)$//g;
    $resonding =~ s/ {2,}/ /g;
    my @teerkoexpertsglobal = split(",",AttrVal($teerkobuild{hashdata}{NAME},"TEERKOExpert",""));
    my @sarsglobal =();
    for my $teerkoexpert(@teerkoexpertsglobal){
        push(@sarsglobal,$1) if($teerkoexpert=~/sar:(.+?)(%|$)/i);
    }
    for my $sarglobal(@sarsglobal){
        if($sarglobal=~ /(.*)=(.*)/i){
            my $search=$1;
            my $replace=$2;
            $resonding =~ s/\!${search}\!/${replace}/ig;
        }
    }
    $resonding =~ s/\!//ig;

    Log3 $teerkobuild{hashdata}{NAME}, 5, $teerkobuild{hashdata}{NAME} . ": +--> Sending Response Sentence";
    my @externaldevices =();
    
    readingsSingleUpdate( $defs{$teerkobuild{hashdata}{NAME}}, "Answer", $resonding, 1 );
    if($teerkobuild{replydata}{to} =~ /^own$/i){
        foreach my $replytodev (split(",",ReadingsVal($teerkobuild{hashdata}{NAME},"OwnAnswer",""))){
            push(@externaldevices,$replytodev);
        }
    }
    if($teerkobuild{replydata}{to} =~ /^telegram/i){
        push(@externaldevices,$teerkobuild{replydata}{device} . ' msg @' . $teerkobuild{replydata}{supply1});
        foreach my $replytodev (split(",",ReadingsVal($teerkobuild{hashdata}{NAME},"TelegramAnswer",""))){
            push(@externaldevices,$replytodev);
        }
    }
    if($teerkobuild{replydata}{to} =~ /^amad/i) {
        if(ReadingsVal($teerkobuild{hashdata}{NAME},"AMADAnswer","") !~ /-(tts|msg)-/i){
            push(@externaldevices,$teerkobuild{replydata}{device} . " screenMsg");
        }
        foreach my $replytodev (split(",",ReadingsVal($teerkobuild{hashdata}{NAME},"AMADAnswer",""))){
            if($replytodev =~ /-tts-/i){
                push(@externaldevices,"(nbr)" . $teerkobuild{replydata}{device} . " ttsMsg");
            }elsif($replytodev =~ /-msg-/i){
                push(@externaldevices,$teerkobuild{replydata}{device} . " screenMsg");
            }else{
                push(@externaldevices,$replytodev);
            }
        }
    }
        

    if($teerkobuild{replydata}{to} =~ /^all/i){
        readingsSingleUpdate( $defs{$teerkobuild{hashdata}{NAME}}, "Answer", $resonding, 1 );
        foreach my $replytodevice (split(",",ReadingsVal($teerkobuild{hashdata}{NAME},"OwnAnswer",""))){
            push(@externaldevices,$replytodevice);
        }
        # ALLE TELEGRAM ACCOUNTS DIE ANGEGEBEN SIND
        foreach my $replytodevice (split(",",AttrVal($teerkobuild{hashdata}{NAME},"TEERKOTelegramDevice", ""))){
            next if(InternalVal($replytodevice,"TYPE","")!~/telegrambot/i);
            for my $devicesupply1 (split(",",AttrVal($teerkobuild{hashdata}{NAME},"TEERKOTelegramPeerId", ""))){
                push(@externaldevices,$replytodevice . " msg @" . $devicesupply1);
                foreach my $replytodev (split(",",ReadingsVal($teerkobuild{hashdata}{NAME},"TelegramAnswer",""))){
                    push(@externaldevices,$replytodev);
                }
            }
        }
        # ALLE AMAD ACCOUNTS DIE ANGEGEBEN SIND
        my @amaddevices = split(",",AttrVal($teerkobuild{hashdata}{NAME},"TEERKOAMADDevice", ""));
        @amaddevices =devspec2array("TYPE=AMADDevice") if(AttrVal($teerkobuild{hashdata}{NAME},"TEERKOAMADDevice","") =~ /-Alle-/i);
        foreach my $replytodevice (split(",",AttrVal($teerkobuild{hashdata}{NAME},"TEERKOAMADDevice", ""))){
            next if(InternalVal($replytodevice,"TYPE","")!~/amad/i);
            if(ReadingsVal($teerkobuild{hashdata}{NAME},"AMADAnswer","") !~ /-(tts|msg)-/i){
                push(@externaldevices,$replytodevice . " screenMsg");
            }
            foreach my $replytodev (split(",",ReadingsVal($teerkobuild{hashdata}{NAME},"AMADAnswer",""))){
                if($replytodev =~ /-tts-/i){
                    push(@externaldevices,"(nbr)" . $replytodevice . " ttsMsg");
                }elsif($replytodev =~ /-msg-/i){
                    push(@externaldevices,$replytodevice . " screenMsg");
                }else{
                    push(@externaldevices,$replytodev);
                }
            }
        }
    }
    for(my $i = scalar @externaldevices -1;$i>=0;$i--){
        $externaldevices[$i] =~ s/^(\s+|\n+)|(\s+|\n+)$//g;
        splice (@externaldevices, $i, 1) if($externaldevices[$i] eq "");
    }
    @externaldevices=TEERKO_DelDouble(@externaldevices);
    
    Log(3,"***DEBUG*** RUNNGING ");
    foreach my $externaldevice (@externaldevices){
        Log(3,"***DEBUG*** EXTERNALANSWER " . $externaldevice);
        my $optionstring = "";
        $optionstring = $1 if($externaldevice =~ /^\((.*)\)/);
        $externaldevice =~ s/^\(.*\)//g;
        my @options = split(";", $optionstring);
        my @externalparts = split(" ", $externaldevice);
        if(!defined($defs{$externalparts[0]})){
            Log3 $teerkobuild{hashdata}{NAME}, 4, $teerkobuild{hashdata}{NAME} . ": +--> Device '". $externalparts[0] ."' doesnt exist for an answer";
            next;
        }else{
            my $devresponding = $resonding;
            my $spacer = " ";
            $devresponding =~ s/\n//g if TEERKO_ValueInArray("nbr",@options);
            $devresponding = "'" . $devresponding . "'" if TEERKO_ValueInArray("qu",@options);
            $devresponding = "\"" . $devresponding . "\"" if TEERKO_ValueInArray("dqu",@options);
            $devresponding = urlEncode($devresponding) if TEERKO_ValueInArray("uen",@options);
            $spacer = "" if TEERKO_ValueInArray("nsp",@options);
            Log(3,"***DEBUG*** EXTERNALANSWER SET: set " . $externaldevice . $spacer . $devresponding);
            fhem("set " . $externaldevice . $spacer . $devresponding);
        }
    }
    

    return %teerkobuild;
}

sub TEERKO_FHEMExecuter{
    my (%teerkobuild) = @_;
    Log3 $teerkobuild{hashdata}{NAME}, 4, $teerkobuild{hashdata}{NAME} . ": Execute all created FHEM Commands";
    
    for(my $i=0;$i<scalar @{$teerkobuild{data}{fhemcommands}};$i++){
        Log3 $teerkobuild{hashdata}{NAME}, 5, $teerkobuild{hashdata}{NAME} . ": +--> Running command '". $teerkobuild{data}{fhemcommands}[$i] . "'";
        fhem($teerkobuild{data}{fhemcommands}[$i]);
    }
    for(my $j=0;$j<scalar @{$teerkobuild{data}{substrings}};$j++){
        for(my $i=0;$i<scalar @{$teerkobuild{data}{substrings}[$j]{fhemcommands}};$i++){
            Log3 $teerkobuild{hashdata}{NAME}, 5, $teerkobuild{hashdata}{NAME} . ": +--> Running command '". $teerkobuild{data}{substrings}[$j]{fhemcommands}[$i] . "'";
            fhem($teerkobuild{data}{substrings}[$j]{fhemcommands}[$i]);
        }
    }
    return %teerkobuild;
}

sub TEERKO_FindActions{
    my (%teerkobuild) = @_;
    Log3 $teerkobuild{hashdata}{NAME}, 4, $teerkobuild{hashdata}{NAME} . ": Search for possible Action";
    
    for my $substr(@{$teerkobuild{data}{substrings}}){
        if(!$$substr{usercommand}){
            my $prio=-1;
            ActionLoop: for my $action(@{$TEERKO_brain{"actions"}}){
                Log3 $teerkobuild{hashdata}{NAME}, 5, $teerkobuild{hashdata}{NAME} . ": +--> Checking Actiontype " . $$action{"type"} . "";
                next ActionLoop if($$action{"moderequired"}!=InternalVal($teerkobuild{hashdata}{NAME},"MODE_".$teerkobuild{replydata}{combined},""));
                #ClassificationLoop:for my $classification(@{$$action{"classification"}}){
                ClassificationLoop: for(my $i=0;$i<scalar @{$$action{"classification"}};$i++){
                    my $classification=$$action{"classification"}[$i];
                    Log3 $teerkobuild{hashdata}{NAME}, 5, $teerkobuild{hashdata}{NAME} . ": +--> ...prio " . $$classification{"prio"} . "";
                    RequiredLoop: for my $required(@{$$classification{"required"}}){
                        next RequiredLoop if($$substr{"content"}=~$required);
                        next ClassificationLoop;
                    }
                    Log3 $teerkobuild{hashdata}{NAME}, 5, $teerkobuild{hashdata}{NAME} . ": +--> ...requirements done";
                    ForbiddenLoop: for my $forbidden(@{$$classification{"forbidden"}}){
                        next ClassificationLoop if($$substr{"content"}=~$forbidden);
                        next ForbiddenLoop;
                    }
                    Log3 $teerkobuild{hashdata}{NAME}, 5, $teerkobuild{hashdata}{NAME} . ": +--> ...forbidden done";
                    next ClassificationLoop if($prio>$$classification{"prio"});
                    $prio=$$classification{"prio"};
                    Log3 $teerkobuild{hashdata}{NAME}, 5, $teerkobuild{hashdata}{NAME} . ": +--> Actiontype is now " . $$action{"type"} . " with prio $prio";
                    $$substr{"action"}={ %{$action} };
                }
            }
        }else{
            $$substr{"action"}={ %{$TEERKO_brain{"actions"}[0]} };
            
        }
    }
    
    return %teerkobuild;
}

sub TEERKO_Substring{
    my (%teerkobuild) = @_;
    Log3 $teerkobuild{hashdata}{NAME}, 4, $teerkobuild{hashdata}{NAME} . ": Limiting the Substrings";
    
    my $beginning_position=-1;
    my $ending_position=-1;
    my $substrid=1;
    TokenLoop: for(my $i=0;$i<scalar @{$teerkobuild{data}{tokens}};$i++){
        $beginning_position=$i if($beginning_position<0);
        $ending_position=$i-1 if($teerkobuild{data}{tokens}[$i]{"type"} eq "dot");
        $ending_position=$i if($i == scalar @{$teerkobuild{data}{tokens}} - 1);
        
        if($beginning_position>=0 && $ending_position>=0){
            my %substringhash = (
                "start"=>$beginning_position,
                "end"=>$ending_position,
                "content"=>"",
                "usercommand"=>0,
                "substrid"=>$substrid,
                "responses"=>[],
                "fhemcommands"=>[],
                "tokens"=>[],
                "action"=>{}
            );
            for(my $j=$beginning_position;$j<=$ending_position;$j++){
                $substringhash{content} .= "token:" . $teerkobuild{data}{tokens}[$j]{"token"} . ":type:" . $teerkobuild{data}{tokens}[$j]{"type"} . ":subtype:" . $teerkobuild{data}{tokens}[$j]{"subtype"} . ":value:" . $teerkobuild{data}{tokens}[$j]{"value"} . ";";
                push(@{$substringhash{"tokens"}},$teerkobuild{data}{tokens}[$j]);
            }
            push(@{$teerkobuild{data}{substrings}},{%substringhash});
            $beginning_position=-1;
            $ending_position=-1;
            $substrid++;
        }
        next TokenLoop if($teerkobuild{data}{tokens}[$i]{"type"} eq "dot");
    }
    my $i = 0;
    for my $substr(@{$teerkobuild{data}{substrings}}){
        Log3 $teerkobuild{hashdata}{NAME}, 5, $teerkobuild{hashdata}{NAME} . ": +--> Substring: '$i' start: '" . $$substr{"start"} . "' end: '" . $$substr{"end"} . "'";
        Log3 $teerkobuild{hashdata}{NAME}, 5, $teerkobuild{hashdata}{NAME} . ": +--> Content: '" . $$substr{"content"} . "'";
        $i++;
    }
    
    return %teerkobuild;
}

sub TEERKO_TokenizingRoomDevice(@){
    my %teerkobuild = @_;
    Log3 $teerkobuild{hashdata}{NAME}, 4, $teerkobuild{hashdata}{NAME} . ": Find Rooms and Devices for possible Tokens";
    
    Log3 $teerkobuild{hashdata}{NAME}, 5, $teerkobuild{hashdata}{NAME} . ": +--> Got all rooms/TeerkoRooms from FHEM SYSTEM";
    my @roomarray=(devspec2array("room!=hidden"),devspec2array("TEERKORoom=.+"),devspec2array("alexaRoom=.+"),devspec2array("roomName=.+:FILTER=TYPE=SONOSPLAYER:FILTER=model!=Sonos_ZB100"));
    my @rooms =(); 
    for my $room (@roomarray){
        @rooms = (@rooms,split(',', AttrVal($room,"room","")),split(',', AttrVal($room,"TEERKORoom","")),split(',', AttrVal($room,"alexaRoom","")),split(',', ReadingsVal($room,"roomName","")))
    }
    for my $room (@rooms){
        $room =~ s/!//g;
    }
    @rooms=TEERKO_DelDouble(@rooms);
    
    Log3 $teerkobuild{hashdata}{NAME}, 5, $teerkobuild{hashdata}{NAME} . ": +--> Got all alias/TEERKOAlias from FHEM SYSTEM";
    my @devicearray=(devspec2array("alias=.+"),devspec2array("TEERKOAlias=.+"),devspec2array("alexaName=.+"));
    @devicearray=TEERKO_DelDouble(@devicearray);
    my @devices =();
    for my $device (@devicearray){
        my %devicehash = (
            "name"=>$device,
            "score"=>0,
            "alias"=>"",
            "room"=>"",
            "aliase"=>[
                split(',', AttrVal($device,"TEERKOAlias","")),
                split(',', AttrVal($device,"alias","")),
                split(',', AttrVal($device,"alexaName",""))
            ],
            "rooms"=>[
                split(',', AttrVal($device,"TEERKORoom","")),
                split(',', AttrVal($device,"room","")),
                split(',', AttrVal($device,"alexaRoom","")),
                split(',', ReadingsVal($device,"roomName",""))
            ]
        );
        @{$devicehash{aliase}}=TEERKO_DelDouble(@{$devicehash{aliase}});
        @{$devicehash{rooms}}=TEERKO_DelDouble(@{$devicehash{rooms}});
        push(@devices,{ %devicehash })
    }
    
    Log3 $teerkobuild{hashdata}{NAME}, 5, $teerkobuild{hashdata}{NAME} . ": +--> Match Making and calculating for D- and RToken";
    my @device_name_array=();
    my $device_det=0;
    my $device_det_start=0;
    my $device_det_end=0;
    
    my @room_name_array=();
    my $room_det=0;
    my $room_det_start=0;
    my $room_det_end=0;
    
    my $plural=0;
    
    my $device_high_start=-1;
    my $device_high_sum=-1;
    
    my $room_high_sum=-1;
    TokenLoop: for(my $i=0;$i<scalar @{$teerkobuild{data}{tokens}};$i++){
        if(($teerkobuild{data}{tokens}[$i]{"type"} =~ /device/i) && !$device_det){
            $device_det=1;
            $device_det_start=$i ;
            $device_det_end=$i ;
        }
        $device_det_end=$i-1 if(($teerkobuild{data}{tokens}[$i]{"type"} !~ /device/i) && $device_det);
        $device_det=0 unless($teerkobuild{data}{tokens}[$i]{"type"} =~ /device/i);
        push(@device_name_array,$teerkobuild{data}{tokens}[$i]{"token"}) if ($device_det);
        $device_det=0 if($i==scalar @{$teerkobuild{data}{tokens}}-1);
        
        if(($teerkobuild{data}{tokens}[$i]{"type"} =~ /room/i) && !$room_det){
            $room_det=1;
            $room_det_start=$i ;
            $room_det_end=$i ;
        }
        $room_det_end=$i-1 if(($teerkobuild{data}{tokens}[$i]{"type"} !~ /room/i) && $room_det);
        $room_det=0 unless($teerkobuild{data}{tokens}[$i]{"type"} =~ /room/i);
        push(@room_name_array,$teerkobuild{data}{tokens}[$i]{"token"}) if ($room_det);
        $room_det=0 if($i==scalar @{$teerkobuild{data}{tokens}}-1);
        
        $plural=0 if(!$device_det && scalar @device_name_array ==0);
        $plural=1 if($teerkobuild{data}{tokens}[$i]{"subtype"} =~ /multiple/i);
        
        
        
        
        if(!$room_det && scalar @room_name_array >0){
            for(my $j=$room_det_start+1;$j<=$room_det_end;$j++){
                $teerkobuild{data}{tokens}[$j]{"type"}="ignore";
                $teerkobuild{data}{tokens}[$j]{"subtype"}="ignore";
                $teerkobuild{data}{tokens}[$room_det_start]{"value"}="";
            }
            my $roomscore=0;
            my $roomname =join(" ", @room_name_array);
            @room_name_array=();
            if(scalar @rooms==0){
                $teerkobuild{data}{tokens}[$room_det_start]{"type"}="error";
                $teerkobuild{data}{tokens}[$room_det_start]{"subtype"}="norooms";
                $teerkobuild{data}{tokens}[$room_det_start]{"value"}="$roomname";
                next TokenLoop;
            }
            #$teerkobuild{data}{tokens}[$room_det_start]{"type"}="ignore";
            #$teerkobuild{data}{tokens}[$room_det_start]{"subtype"}="lowscoreroom";
            #$teerkobuild{data}{tokens}[$room_det_start]{"value"}="$roomname";
            RoomMatch: for my $room (@rooms){
                $roomscore = TEERKO_QgramScore($roomname,$room);
                if($roomscore<0.5){
                    $teerkobuild{data}{tokens}[$room_det_start]{"type"}="ignore";
                    $teerkobuild{data}{tokens}[$room_det_start]{"subtype"}="lowscoreroom";
                    $teerkobuild{data}{tokens}[$room_det_start]{"value"}="$roomname";
                    next RoomMatch;
                }
                if($roomscore<0.8){
                    $teerkobuild{data}{tokens}[$room_det_start]{"type"}="ignore";
                    $teerkobuild{data}{tokens}[$room_det_start]{"subtype"}="lowscoreroom";
                    $teerkobuild{data}{tokens}[$room_det_start]{"value"}="$roomname";
                    next RoomMatch;
                }
                if($roomscore == 1){
                    $teerkobuild{data}{tokens}[$room_det_start]{"type"}="room";
                    $teerkobuild{data}{tokens}[$room_det_start]{"subtype"}="room";
                    $teerkobuild{data}{tokens}[$room_det_start]{"value"}="$room";
                    $room_high_sum=-1;
                    my $rpsearchstart =0;
                    $rpsearchstart=$room_det_start-3 if($room_det_start>2);
                    my $saverp=0;
                    my $rp ="";
                    for(my $j = $rpsearchstart;$j<$room_det_start;$j++){
                        $saverp=1 if($teerkobuild{data}{tokens}[$j]{"type"} eq "rpreposition");
                        $rp .= $teerkobuild{data}{tokens}[$j]{"token"} . " " if ($saverp);
                    }
                    #readingsSingleUpdate( $teerkobuild{hashdata}{hash}, "." . $room . "_preposition", $rp, 0 ) if($rp ne "");
                    next TokenLoop;
                }
                next RoomMatch if ($roomscore<$room_high_sum);
                $teerkobuild{data}{tokens}[$room_det_start]{"type"}="room";
                $teerkobuild{data}{tokens}[$room_det_start]{"subtype"}="room";
                $teerkobuild{data}{tokens}[$room_det_start]{"value"}="$room";
                #predicate search and save
                my $rpsearchstart =0;
                $rpsearchstart=$room_det_start-3 if($room_det_start>2);
                my $saverp=0;
                my $rp ="";
                for(my $j = $rpsearchstart;$j<$room_det_start;$j++){
                    $saverp=1 if($teerkobuild{data}{tokens}[$j]{"type"} eq "rpreposition");
                    $rp .= $teerkobuild{data}{tokens}[$j]{"token"} . " " if ($saverp);
                }
                #readingsSingleUpdate( $teerkobuild{hashdata}{hash}, ".".$room . "_preposition", $rp, 0 ) if($rp ne "");
                $room_high_sum=$roomscore;
            }
            $room_high_sum=-1;
        }
            
        if(!$device_det && scalar @device_name_array >0){
            for(my $j=$device_det_start+1;$j<=$device_det_end;$j++){
                $teerkobuild{data}{tokens}[$j]{"type"}="ignore";
                $teerkobuild{data}{tokens}[$j]{"subtype"}="ignore";
                $teerkobuild{data}{tokens}[$j]{"value"}="";
            }
            my $devsore = 0;
            my $devicename =join(" ", @device_name_array);
            @device_name_array=();
            if(scalar @devices==0){
                $teerkobuild{data}{tokens}[$device_det_start]{"type"}="error";
                $teerkobuild{data}{tokens}[$device_det_start]{"subtype"}="nodevices";
                $teerkobuild{data}{tokens}[$device_det_start]{"value"}="$devicename";
                Log3 $teerkobuild{hashdata}{NAME}, 5, $teerkobuild{hashdata}{NAME} . ": +--> No Aliase/TEERKOAlias in FHEM SYSTEM found";
                next TokenLoop;
            }
            DeviceMatch: for my $device (@devices){
                AliasMatch: for my $alias (@{$$device{"aliase"}}){
                    $devsore = TEERKO_QgramScore($devicename,$alias =~ s/!//gr);
                    if($devsore < 1){
                        if($plural){
                            #Log3 $teerkobuild{hashdata}{NAME}, 5, $teerkobuild{hashdata}{NAME} . ": +--> Plural device";
                            my $tempscore = 0;
                            $tempscore = TEERKO_QgramScore($devicename,$alias =~ s/$/N/gr =~ s/!//gr)if($tempscore<1);
                            $devsore = $tempscore if ($tempscore>$devsore);
                            $tempscore = TEERKO_QgramScore($devicename,$alias =~ s/$/ER/gr =~ s/!//gr)if($tempscore<1);
                            $devsore = $tempscore if ($tempscore>$devsore);
                            $tempscore = TEERKO_QgramScore($devicename,$alias =~ s/$/EN/gr =~ s/!//gr)if($tempscore<1);
                            $devsore = $tempscore if ($tempscore>$devsore);
                            $tempscore = TEERKO_QgramScore($devicename,$alias =~ s/$/S/gr =~ s/!//gr)if($tempscore<1);
                            $devsore = $tempscore if ($tempscore>$devsore);
                            $tempscore = TEERKO_QgramScore($devicename,$alias =~ s/$/ES/gr =~ s/!//gr)if($tempscore<1);
                            $devsore = $tempscore if ($tempscore>$devsore);
                        }
                    }
                    Log3 $teerkobuild{hashdata}{NAME}, 5, $teerkobuild{hashdata}{NAME} . ": +--> The Scoring of '$devicename' against '$alias' = $devsore (PLURAL: $plural)";
                    next AliasMatch if ($devsore<$$device{"score"});
                    #$teerkobuild{data}{tokens}[$device_det_start]{"value"}="$devicename";
                    $$device{"alias"}=$alias;
                    $$device{"score"}=$devsore;
                    if($$device{"alias"}!~/!/){
                        Log3 $teerkobuild{hashdata}{NAME}, 5, $teerkobuild{hashdata}{NAME} . ": +--> Alias is not primary Alias";
                        for my $prefalias (@{$$device{"aliase"}}){
                            $$device{"alias"}=$prefalias if($prefalias=~/!/);
                            Log3 $teerkobuild{hashdata}{NAME}, 5, $teerkobuild{hashdata}{NAME} . ": +--> Found primary Alias" if($prefalias=~/!/);
                            last if($prefalias=~/!/);
                        }
                    }
                    $$device{"alias"} =~ s/!//g;
                    #$teerkobuild{data}{tokens}[$device_det_start]{"value"}=$$device{"alias"};

                    last AliasMatch if ($devsore==1);
                }
            }
            my @devices =  sort { $b->{score} <=> $a->{score} } @devices;

            my $scorerem=$devices[0]{"score"};
            if($scorerem<0.5){
                $teerkobuild{data}{tokens}[$device_det_start]{"type"}="ignore";
                $teerkobuild{data}{tokens}[$device_det_start]{"subtype"}="token";
                $teerkobuild{data}{tokens}[$device_det_start]{"value"}=$teerkobuild{data}{tokens}[$device_det_start]{"token"};
                Log3 $teerkobuild{hashdata}{NAME}, 5, $teerkobuild{hashdata}{NAME} . ": +-->+--> Set " . $teerkobuild{data}{tokens}[$device_det_start]{"type"} . " to lowscoredevice";
                next TokenLoop;
            }elsif($scorerem<0.8){
                $teerkobuild{data}{tokens}[$device_det_start]{"type"}="ignore";
                $teerkobuild{data}{tokens}[$device_det_start]{"subtype"}="lowscoredevice";
                $teerkobuild{data}{tokens}[$device_det_start]{"value"}=$devicename;
                Log3 $teerkobuild{hashdata}{NAME}, 5, $teerkobuild{hashdata}{NAME} . ": +-->+--> Set " . $teerkobuild{data}{tokens}[$device_det_start]{"type"} . " to lowscoredevice";
                next TokenLoop;
            }else{
                for(my $j=0;$j<scalar @devices;$j++){
                    if($devices[$j]{"score"}==$scorerem){
                        push(@{$teerkobuild{data}{tokens}[$device_det_start]{"devicelist"}},{ %{$devices[$j]} });
                    }else{
                        last;
                    }
                }
            }
            
            $teerkobuild{data}{tokens}[$device_det_start]{"multidevice"}=1 if($plural);
            Log3 $teerkobuild{hashdata}{NAME}, 5, $teerkobuild{hashdata}{NAME} . ": +-->+--> Set all Devices after matching to scoring 0";
            for my $sdevice (@devices){
                $$sdevice{"score"}=0;
            }
        }
    }
    Log3 $teerkobuild{hashdata}{NAME}, 5, $teerkobuild{hashdata}{NAME} . ": +--> Tokenizing result";
    my $i =0;
    for my $token(@{$teerkobuild{data}{tokens}}){
        Log3 $teerkobuild{hashdata}{NAME}, 5, $teerkobuild{hashdata}{NAME} . ": +--> Token: '$i' Word: '" . $$token{"token"} . "' Type: '" . $$token{"type"} . "' Subtype: '" . $$token{"subtype"} . "' Value: '" . $$token{"value"} . "'";
        $i++;
    }
    
    return %teerkobuild;
}

sub TEERKO_ArticleFinder{
    my ($substrarray, $person, %teerkobuild) = @_;
    Log3 $teerkobuild{hashdata}{NAME}, 5, $teerkobuild{hashdata}{NAME} . ": +--> Running Article Finder";
    Log3 $teerkobuild{hashdata}{NAME}, 5, $teerkobuild{hashdata}{NAME} . ": +-->+--> Substring: " . $substrarray;
    
    for(my $a = 0; $a < scalar @{$teerkobuild{data}{substrings}[$substrarray]{"tokens"}};$a++){
            Log3 $teerkobuild{hashdata}{NAME}, 5, $teerkobuild{hashdata}{NAME} . ": +-->+--> TOKEN: " .$teerkobuild{data}{substrings}[$substrarray]{"tokens"}[$a]{"token"} ;
        if($teerkobuild{data}{substrings}[$substrarray]{"tokens"}[$a]{type} =~ /device/i){
            Log3 $teerkobuild{hashdata}{NAME}, 5, $teerkobuild{hashdata}{NAME} . ": +-->+-->+--> SEARCH ARTICLE";
            Log3 $teerkobuild{hashdata}{NAME}, 5, $teerkobuild{hashdata}{NAME} . ": +-->+-->+--> FOUND ARTICLE " . $teerkobuild{data}{substrings}[$substrarray]{"tokens"}[$a-1]{"token"}
                if($a > 0 && $teerkobuild{data}{substrings}[$substrarray]{"tokens"}[$a-1]{"type"} eq "article");
            my $farticle ="";
            $farticle=lc($teerkobuild{data}{substrings}[$substrarray]{"tokens"}[$a-1]{"token"}) if($a > 0 && $teerkobuild{data}{substrings}[$substrarray]{"tokens"}[$a-1]{"type"} eq "article");
            readingsSingleUpdate( $defs{$teerkobuild{hashdata}{NAME}}, "." . $teerkobuild{data}{substrings}[$substrarray]{"tokens"}[$a]{"devicelist"}[0]{"alias"} . "_dafp", $farticle, 0 ) 
                if($farticle ne "" && $person == 1 && scalar @{$teerkobuild{data}{substrings}[$substrarray]{"tokens"}[$a]{"devicelist"}} > 0);
            readingsSingleUpdate( $defs{$teerkobuild{hashdata}{NAME}}, "." . $teerkobuild{data}{substrings}[$substrarray]{"tokens"}[$a]{"devicelist"}[0]{"alias"} . "_dasp", $farticle, 0 ) 
                if($farticle ne "" && $person == 2 && scalar @{$teerkobuild{data}{substrings}[$substrarray]{"tokens"}[$a]{"devicelist"}} > 0);
        
            next;
        }
        if($teerkobuild{data}{substrings}[$substrarray]{"tokens"}[$a]{type} =~ /lowscoredevice/i){
            Log3 $teerkobuild{hashdata}{NAME}, 5, $teerkobuild{hashdata}{NAME} . ": +-->+-->+--> SEARCH ARTICLE";
            Log3 $teerkobuild{hashdata}{NAME}, 5, $teerkobuild{hashdata}{NAME} . ": +-->+-->+--> FOUND ARTICLE " . $teerkobuild{data}{substrings}[$substrarray]{"tokens"}[$a-1]{"token"}
                if($a > 0 && $teerkobuild{data}{substrings}[$substrarray]{"tokens"}[$a-1]{"type"} eq "article");
            my $farticle ="";
            $farticle=lc($teerkobuild{data}{substrings}[$substrarray]{"tokens"}[$a-1]{"token"}) if($a > 0 && $teerkobuild{data}{substrings}[$substrarray]{"tokens"}[$a-1]{"type"} eq "article");
            readingsSingleUpdate( $defs{$teerkobuild{hashdata}{NAME}}, "." . $teerkobuild{data}{substrings}[$substrarray]{"tokens"}[$a]{"value"} . "_dafp", $farticle, 0 ) 
                if($farticle ne "" && $person == 1 && scalar @{$teerkobuild{data}{substrings}[$substrarray]{"tokens"}[$a]{"devicelist"}} > 0);
            readingsSingleUpdate( $defs{$teerkobuild{hashdata}{NAME}}, "." . $teerkobuild{data}{substrings}[$substrarray]{"tokens"}[$a]{"value"} . "_dasp", $farticle, 0 ) 
                if($farticle ne "" && $person == 2 && scalar @{$teerkobuild{data}{substrings}[$substrarray]{"tokens"}[$a]{"devicelist"}} > 0);
        
            next;
        }
        if($teerkobuild{data}{substrings}[$substrarray]{"tokens"}[$a]{type} =~ /lowscoreroom|room/i){
            Log3 $teerkobuild{hashdata}{NAME}, 5, $teerkobuild{hashdata}{NAME} . ": +-->+-->+--> SEARCH PREPOSITION";
            Log3 $teerkobuild{hashdata}{NAME}, 5, $teerkobuild{hashdata}{NAME} . ": +-->+-->+--> FOUND PREPOSITION " . $teerkobuild{data}{substrings}[$substrarray]{"tokens"}[$a-1]{"token"}
                if($a > 0 && ($teerkobuild{data}{substrings}[$substrarray]{"tokens"}[$a-1]{"type"} eq "rpreposition" || $teerkobuild{data}{substrings}[$substrarray]{"tokens"}[$a-2]{"type"} eq "rpreposition"));
            my $farticle ="";
            if($a > 0 && $teerkobuild{data}{substrings}[$substrarray]{"tokens"}[$a-1]{"type"} eq "rpreposition"){
                $farticle=lc($teerkobuild{data}{substrings}[$substrarray]{"tokens"}[$a-1]{"token"});
                readingsSingleUpdate( $defs{$teerkobuild{hashdata}{NAME}}, "." . $teerkobuild{data}{substrings}[$substrarray]{"tokens"}[$a]{"value"} . "_rpp", $farticle, 0 ) ;
                next;
            }
            if($a > 1 && $teerkobuild{data}{substrings}[$substrarray]{"tokens"}[$a-2]{"type"} eq "rpreposition"){
                $farticle=lc($teerkobuild{data}{substrings}[$substrarray]{"tokens"}[$a-2]{"token"} . " " . $teerkobuild{data}{substrings}[$substrarray]{"tokens"}[$a-1]{"token"});
                readingsSingleUpdate( $defs{$teerkobuild{hashdata}{NAME}}, "." . $teerkobuild{data}{substrings}[$substrarray]{"tokens"}[$a]{"value"} . "_rpp", $farticle, 0 ) ;
                next;
            }
        
            next;
        }
    }
    
    return %teerkobuild;
}

sub TEERKO_CommandPreperations{ #Function to prepare the command. Replace special chars ...
    my %teerkobuild = @_;
    Log3 $teerkobuild{hashdata}{NAME}, 4, $teerkobuild{hashdata}{NAME} . ": Command Preperations";
    
    my @timetextarray =("null","einer","zwei","drei","vier","fünf","sechs","sieben","acht","neun","zehn");
    for(my $i=1;$i<=10;$i++){
        my $letternumber = $timetextarray[$i];
        $teerkobuild{pcommand} =~ s/\bin ${letternumber} (Minute|Minuten|Stunde|Stunden|Sekunde|Sekunden)/in $i $1/gi;
    }
    
    @timetextarray =("null","ersten","zweiten","dritten","vierten","fünften","sechsten","siebten","achten","neunten","zehnten");
    while ($teerkobuild{pcommand} =~ /\b(im|auf dem) (\d+)\./i){
        my $findnumber=$2;
        $findnumber=10 if($findnumber>10);
        my $letternumber = $timetextarray[$findnumber];
        $teerkobuild{pcommand} =~ s/\b(im|auf dem) (\d+)\./$1 ${letternumber}/gi;
    }
    
    @timetextarray =("null","erste","zweite","dritte","vierte","fünfte","sechste","siebte","achte","neunte","zehnte");
    while ($teerkobuild{pcommand} =~ /^(\d+)\./i){
        my $findnumber=$1;
        $findnumber=10 if($findnumber>10);
        my $letternumber = $timetextarray[$findnumber];
        $teerkobuild{pcommand} =~ s/^\d+\.\./${letternumber}/gi;
    }
    while ($teerkobuild{pcommand} =~ /(der|die|das|den) (\d+)\./i){
        my $findnumber=$2;
        $findnumber=10 if($findnumber>10);
        my $letternumber = $timetextarray[$findnumber];
        $teerkobuild{pcommand} =~ s/\b(der|die|das|den) (\d+)\./$1 ${letternumber}/gi;
    }
    
    $teerkobuild{pcommand} =~ s/(.[A-Za-z0-9]+)(.|)\.(.|)(.[A-Za-z]+)/$1 \. $4/gi;              #Getrennte Saetze mit auseinandergezogenem Punkt für das Tokenizing
    $teerkobuild{pcommand} =~ s/(\d+)(.|)\,(.|)(\d+)/$1.$4/g;                             #Ersetze bei Floating Zahlen das Comma mit einem Punkt
    $teerkobuild{pcommand} =~ s/%/ Prozent/g;                                             #Ersetze das Prozent Zeichen durch das Wort
    $teerkobuild{pcommand} =~ tr/A-Za-z0-9.ÄäÖöÜüß //dc;                                            #Loesche alle nicht mehr zu verwendenen Zeichen.
    
    return %teerkobuild;
}

sub TEERKO_Tokenizing{
    my %teerkobuild = @_;
    Log3 $teerkobuild{hashdata}{NAME}, 4, $teerkobuild{hashdata}{NAME} . ": Tokenizing the Command";
    
    my @tokens = split(" ",$teerkobuild{pcommand});
    
    for my $token(@tokens){
        my %tokenhash=(
            "token"=>$token,
            "type"=>"",
            "subtype"=>"",
            "value"=>"",
            "devicelist"=>[],
            "multidevice"=>0,
        );
        push(@{$teerkobuild{data}{tokens}},{%tokenhash});
    }
  
    Log3 $teerkobuild{hashdata}{NAME}, 5, $teerkobuild{hashdata}{NAME} . ": +--> TokenLoop 5 Times on " . scalar @{$teerkobuild{data}{tokens}} . " Tokens";

    for(my $k=1;$k<=3;$k++) {
        Log3 $teerkobuild{hashdata}{NAME}, 5, $teerkobuild{hashdata}{NAME} . ": +-->+--> Loop " . $k;
        TokenLoop: for(my $i=0;$i<scalar @{$teerkobuild{data}{tokens}};$i++){
            VocabularyLoop: foreach my $vocabulary_entry (@{$TEERKO_brain{"vocabulary"}}){
                my $checker =0;
                my $mapchecker=0;
                #next VocabularyLoop if($teerkobuild{data}{tokens}[$i]{"type"} eq $$vocabulary_entry{"type"} && $teerkobuild{data}{tokens}[$i]{"subtype"} eq $$vocabulary_entry{"subtype"});
                AnalyseLoop: foreach my $analyse_entry (@{$$vocabulary_entry{"analysis"}}){
                    my $regex = $$analyse_entry{"mappedtoken"};
                    if($teerkobuild{data}{tokens}[$i]{"token"} =~ /^(${regex})$/i){
                        $mapchecker=1;
                    }else{
                        $mapchecker=0;
                        next AnalyseLoop ;
                    }
                    my $analysechecker = 1;
                    Log3 $teerkobuild{hashdata}{NAME}, 5, $teerkobuild{hashdata}{NAME} . ": +-->+-->+--> ***NEW ANALYSE LOOP***MATCHED";
                    Log3 $teerkobuild{hashdata}{NAME}, 5, $teerkobuild{hashdata}{NAME} . ": +-->+-->+--> TOKEN: ".$teerkobuild{data}{tokens}[$i]{"token"}." REGEXP(mappedtoken): ".$regex." TYPE ".$$vocabulary_entry{"type"}." SUBTYPE ".$$vocabulary_entry{"subtype"};
                    
                    Log3 $teerkobuild{hashdata}{NAME}, 5, $teerkobuild{hashdata}{NAME} . ": +-->+-->+--> RUNNGING BrequiredLoop";
                    BrequiredLoop: for(my $l=0;$l<scalar @{$$analyse_entry{"brequired"}};$l++){
                    #BrequiredLoop: while( my( $key, $value ) = each %{$$analyse_entry{"brequired"}} ){
                        my ($key, $type, $value) = $$analyse_entry{"brequired"}[$l] =~ /(\d*):(type|subtype|token|value):(.*)/i;
                        Log3 $teerkobuild{hashdata}{NAME}, 5, $teerkobuild{hashdata}{NAME} . ": +-->+-->+-->+--> Requirement $key $value";
                        my @rangearray = $key =~ /^([1-4])?([1-4])?([1-4])?([1-4])$/;
                        if(scalar @rangearray >0){
                            @rangearray = grep defined, @rangearray;
                            @rangearray = sort @rangearray;
                            my $range = $rangearray[scalar @rangearray -1];
                            if($i-$range<0){
                                $analysechecker = 0;
                                Log3 $teerkobuild{hashdata}{NAME}, 5, $teerkobuild{hashdata}{NAME} . ": +-->+-->+-->+--> FAILED Out of range";
                                last BrequiredLoop;
                            }
                            for(my $j = 1; $j<=$range;$j++){
                                if($$vocabulary_entry{"cancelconjunjunction"} && $teerkobuild{data}{tokens}[$i-$j]{"type"} =~ /conjunction/i){
                                    $analysechecker = 0;
                                    Log3 $teerkobuild{hashdata}{NAME}, 5, $teerkobuild{hashdata}{NAME} . ": +-->+-->+-->+--> FAILED Reached Conjunctione";
                                    last BrequiredLoop;
                                }
                                if($key =~ /${j}/i){
                                    unless ($teerkobuild{data}{tokens}[$i-$j]{$type}=~ /${value}/i){
                                        $analysechecker = 0;
                                        Log3 $teerkobuild{hashdata}{NAME}, 5, $teerkobuild{hashdata}{NAME} . ": +-->+-->+-->+--> Requirement not match";
                                        Log3 $teerkobuild{hashdata}{NAME}, 5, $teerkobuild{hashdata}{NAME} . ": +-->+-->+-->+-->+--> REQUIRED KEY: -$j $type $value";
                                        Log3 $teerkobuild{hashdata}{NAME}, 5, $teerkobuild{hashdata}{NAME} . ": +-->+-->+-->+-->+--> REQUIRED IS: -$j $type ".$teerkobuild{data}{tokens}[$i-$j]{$type};
                                        last BrequiredLoop;
                                    }
                                }
                            }
                        }
                    }
                    Log3 $teerkobuild{hashdata}{NAME}, 5, $teerkobuild{hashdata}{NAME} . ": +-->+-->+--> NEXT ANALYSE 'CAUSE analysechecker is failed" unless ($analysechecker);
                    next AnalyseLoop unless ($analysechecker);

                    Log3 $teerkobuild{hashdata}{NAME}, 5, $teerkobuild{hashdata}{NAME} . ": +-->+-->+--> RUNNGING ArequiredLoop";
                    ArequiredLoop: for(my $l=0;$l<scalar @{$$analyse_entry{"arequired"}};$l++){
                    #ArequiredLoop: while( my( $key, $value ) = each %{$$analyse_entry{"arequired"}} ){
                        my ($key, $type, $value) = $$analyse_entry{"arequired"}[$l] =~ /(\d*):(type|subtype|token|value):(.*)/i;
                        Log3 $teerkobuild{hashdata}{NAME}, 5, $teerkobuild{hashdata}{NAME} . ": +-->+-->+-->+--> Requirement $key $value";
                        my @rangearray = $key =~ /^([1-4])?([1-4])?([1-4])?([1-4])$/;
                        if(scalar @rangearray >0){
                            @rangearray = grep defined, @rangearray;
                            @rangearray = sort @rangearray;
                            my $range = $rangearray[scalar @rangearray -1];
                            if($i+$range>=scalar @{$teerkobuild{data}{tokens}}){
                                Log3 $teerkobuild{hashdata}{NAME}, 5, $teerkobuild{hashdata}{NAME} . ": +-->+-->+-->+--> FAILED Out of range";
                                $analysechecker = 0;
                                last ArequiredLoop;
                            }
                            for(my $j = 1; $j<=$range;$j++){
                                if($$vocabulary_entry{"cancelconjunjunction"} && $teerkobuild{data}{tokens}[$i+$j]{"type"} =~ /conjunction/i){
                                    Log3 $teerkobuild{hashdata}{NAME}, 5, $teerkobuild{hashdata}{NAME} . ": +-->+-->+-->+--> FAILED Reached Conjunctione";
                                    $analysechecker = 0;
                                    last ArequiredLoop;
                                }
                                if($key =~ /${j}/i){

                                    unless ($teerkobuild{data}{tokens}[$i+$j]{$type}=~ /${value}/i){
                                        $analysechecker = 0;
                                        Log3 $teerkobuild{hashdata}{NAME}, 5, $teerkobuild{hashdata}{NAME} . ": +-->+-->+-->+--> Requirement not match";
                                        Log3 $teerkobuild{hashdata}{NAME}, 5, $teerkobuild{hashdata}{NAME} . ": +-->+-->+-->+-->+--> REQUIRED KEY: +$j $type $value";
                                        Log3 $teerkobuild{hashdata}{NAME}, 5, $teerkobuild{hashdata}{NAME} . ": +-->+-->+-->+-->+--> REQUIRED IS: +$j $type ".$teerkobuild{data}{tokens}[$i+$j]{$type};
                                        last ArequiredLoop;
                                    }
                                }
                            }
                        }
                    }
                    Log3 $teerkobuild{hashdata}{NAME}, 5, $teerkobuild{hashdata}{NAME} . ": +-->+-->+--> NEXT ANALYSE 'CAUSE analysechecker is failed" unless ($analysechecker);
                    next AnalyseLoop unless ($analysechecker);
                    
                    Log3 $teerkobuild{hashdata}{NAME}, 5, $teerkobuild{hashdata}{NAME} . ": +-->+-->+--> RUNNGING BforbiddenLoop";
                    BforbiddenLoop: for(my $l=0;$l<scalar @{$$analyse_entry{"bforbidden"}};$l++){
                    #BforbiddenLoop: while( my( $key, $value ) = each %{$$analyse_entry{"bforbidden"}} ){
                        my ($key, $type, $value) = $$analyse_entry{"bforbidden"}[$l] =~ /(\d*):(type|subtype|token|value):(.*)/i;
                        Log3 $teerkobuild{hashdata}{NAME}, 5, $teerkobuild{hashdata}{NAME} . ": +-->+-->+-->+--> Forbidden $key $value";
                        my @rangearray = $key =~ /^([1-4])?([1-4])?([1-4])?([1-4])$/;
                        if(scalar @rangearray >0){
                            @rangearray = grep defined, @rangearray;
                            @rangearray = sort @rangearray;
                            my $range = $rangearray[scalar @rangearray -1];
                            if($i-$range<0){
                                next BforbiddenLoop;
                            }
                            for(my $j = 1; $j<=$range;$j++){
                                if($$vocabulary_entry{"cancelconjunjunction"} && $teerkobuild{data}{tokens}[$i-$j]{"type"} =~ /conjunction/i){
                                    next BforbiddenLoop;
                                }
                                if($key =~ /${j}/i){
                                    if ($teerkobuild{data}{tokens}[$i-$j]{$type}=~ /${value}/i){
                                        $analysechecker = 0;
                                        Log3 $teerkobuild{hashdata}{NAME}, 5, $teerkobuild{hashdata}{NAME} . ": +-->+-->+-->+--> FORBIDDEN match";
                                        Log3 $teerkobuild{hashdata}{NAME}, 5, $teerkobuild{hashdata}{NAME} . ": +-->+-->+-->+-->+--> FORBIDDEN KEY: -$j $type $value";
                                        Log3 $teerkobuild{hashdata}{NAME}, 5, $teerkobuild{hashdata}{NAME} . ": +-->+-->+-->+-->+--> FORBIDDEN IS: -$j $type ".$teerkobuild{data}{tokens}[$i-$j]{$type};
                                        last BforbiddenLoop;
                                    }
                                }
                            }
                        }
                    }
                    Log3 $teerkobuild{hashdata}{NAME}, 5, $teerkobuild{hashdata}{NAME} . ": +-->+-->+--> NEXT ANALYSE 'CAUSE analysechecker is failed" unless ($analysechecker);
                    next AnalyseLoop unless ($analysechecker);
                    
                    Log3 $teerkobuild{hashdata}{NAME}, 5, $teerkobuild{hashdata}{NAME} . ": +-->+-->+--> RUNNGING AforbiddenLoop";
                    AforbiddenLoop: for(my $l=0;$l<scalar @{$$analyse_entry{"aforbidden"}};$l++){
                    #AforbiddenLoop: while( my( $key, $value ) = each %{$$analyse_entry{"aforbidden"}} ){
                        my ($key, $type, $value) = $$analyse_entry{"aforbidden"}[$l] =~ /(\d*):(type|subtype|token|value):(.*)/i;
                        Log3 $teerkobuild{hashdata}{NAME}, 5, $teerkobuild{hashdata}{NAME} . ": +-->+-->+-->+--> Forbidden $key $value";
                        my @rangearray = $key =~ /^([1-4])?([1-4])?([1-4])?([1-4])$/;
                        if(scalar @rangearray >0){
                            @rangearray = grep defined, @rangearray;
                            @rangearray = sort @rangearray;
                            my $range = $rangearray[scalar @rangearray -1];
                            if($i+$range>=scalar @{$teerkobuild{data}{tokens}}){
                                next AforbiddenLoop;
                            }
                            for(my $j = 0; $j<=$range;$j++){
                                if($$vocabulary_entry{"cancelconjunjunction"} && $teerkobuild{data}{tokens}[$i+$j]{"type"} =~ /conjunction/i){
                                    next AforbiddenLoop;
                                }
                                if($key =~ /${j}/i){
                                    if ($teerkobuild{data}{tokens}[$i+$j]{$type}=~ /${value}/i){
                                        $analysechecker = 0;
                                        Log3 $teerkobuild{hashdata}{NAME}, 5, $teerkobuild{hashdata}{NAME} . ": +-->+-->+-->+--> FORBIDDEN match";
                                        Log3 $teerkobuild{hashdata}{NAME}, 5, $teerkobuild{hashdata}{NAME} . ": +-->+-->+-->+-->+--> FORBIDDEN KEY: +$j $type $value";
                                        Log3 $teerkobuild{hashdata}{NAME}, 5, $teerkobuild{hashdata}{NAME} . ": +-->+-->+-->+-->+--> FORBIDDEN IS: +$j $type ".$teerkobuild{data}{tokens}[$i+$j]{$type};
                                        last AforbiddenLoop;
                                    }
                                }
                            }
                        }
                    }
                    Log3 $teerkobuild{hashdata}{NAME}, 5, $teerkobuild{hashdata}{NAME} . ": +-->+-->+--> NEXT ANALYSE 'CAUSE analysechecker is failed" unless ($analysechecker);
                    next AnalyseLoop unless ($analysechecker);
                    if($analysechecker){
                        
                        $checker=1 ;
                        last AnalyseLoop;
                    }
                }
                next VocabularyLoop unless($mapchecker);
                if($checker && ($teerkobuild{data}{tokens}[$i]{"type"} ne $$vocabulary_entry{"type"} || $teerkobuild{data}{tokens}[$i]{"subtype"} ne $$vocabulary_entry{"subtype"})){
                    $teerkobuild{data}{tokens}[$i]{"type"}=$$vocabulary_entry{"type"};
                    $teerkobuild{data}{tokens}[$i]{"subtype"}=$$vocabulary_entry{"subtype"};
                    $teerkobuild{data}{tokens}[$i]{"value"}=$teerkobuild{data}{tokens}[$i]{"token"};
                    Log3 $teerkobuild{hashdata}{NAME}, 5, $teerkobuild{hashdata}{NAME} . ": +-->+-->+--> GOT Tokentype for " . $teerkobuild{data}{tokens}[$i]{"token"} . "(TYPE: " . $teerkobuild{data}{tokens}[$i]{"type"} . " SUBTYPE: " . $teerkobuild{data}{tokens}[$i]{"subtype"} . ")";
                }elsif(!$checker && $teerkobuild{data}{tokens}[$i]{"type"} eq $$vocabulary_entry{"type"} && $teerkobuild{data}{tokens}[$i]{"subtype"} eq $$vocabulary_entry{"subtype"}){
                    Log3 $teerkobuild{hashdata}{NAME}, 5, $teerkobuild{hashdata}{NAME} . ": +-->+-->+--> DELETE Tokentype for " . $teerkobuild{data}{tokens}[$i]{"token"} . "(TYPE: " . $teerkobuild{data}{tokens}[$i]{"type"} . " SUBTYPE: " . $teerkobuild{data}{tokens}[$i]{"subtype"} . ")";
                    $teerkobuild{data}{tokens}[$i]{"type"}="";
                    $teerkobuild{data}{tokens}[$i]{"subtype"}="";
                    $teerkobuild{data}{tokens}[$i]{"value"}="";
                }
                
            }
        }
    }

    Log3 $teerkobuild{hashdata}{NAME}, 5, $teerkobuild{hashdata}{NAME} . ": +--> Possible Room and Device Tokens for all unknown";
    my $room_prep=0;
    my $room_det=0;
    my $plural_prep=0;
    my $plural_det=0;
    for(my $i=0;$i<scalar @{$teerkobuild{data}{tokens}};$i++){
        $room_prep=1 if($teerkobuild{data}{tokens}[$i]{"type"} =~ /rpreposition/i);
            Log3 $teerkobuild{hashdata}{NAME}, 5, $teerkobuild{hashdata}{NAME} . ": +-->+--> Set Found Preposition " . $teerkobuild{data}{tokens}[$i]{"token"} if($room_prep);
        $room_det=1 if($room_prep && $teerkobuild{data}{tokens}[$i]{"type"} eq "");
            Log3 $teerkobuild{hashdata}{NAME}, 5, $teerkobuild{hashdata}{NAME} . ": +-->+--> Found Room " . $teerkobuild{data}{tokens}[$i]{"token"} if($room_det);
        $room_prep=0 if($room_det || $teerkobuild{data}{tokens}[$i]{"type"} eq "room");
            Log3 $teerkobuild{hashdata}{NAME}, 5, $teerkobuild{hashdata}{NAME} . ": +-->+--> Delete Found Preposition " . $teerkobuild{data}{tokens}[$i]{"token"} if(!$room_prep);
        $room_det=0 if($room_det && $teerkobuild{data}{tokens}[$i]{"type"} =~ /.+/i);
            Log3 $teerkobuild{hashdata}{NAME}, 5, $teerkobuild{hashdata}{NAME} . ": +-->+--> Room Ended " . $teerkobuild{data}{tokens}[$i]{"token"} if(!$room_det);

        
        if($room_det && $teerkobuild{data}{tokens}[$i]{"type"} eq ""){
            $teerkobuild{data}{tokens}[$i]{"type"}="room";
            $teerkobuild{data}{tokens}[$i]{"subtype"}="room";
            $teerkobuild{data}{tokens}[$i]{"value"}=$teerkobuild{data}{tokens}[$i]{"token"};
            Log3 $teerkobuild{hashdata}{NAME}, 5, $teerkobuild{hashdata}{NAME} . ": +-->+--> Possible Room " . $teerkobuild{data}{tokens}[$i]{"token"};
        }elsif(!$room_det && $teerkobuild{data}{tokens}[$i]{"type"} eq ""){
            $teerkobuild{data}{tokens}[$i]{"type"}="device";
            $teerkobuild{data}{tokens}[$i]{"subtype"}="device";
            $teerkobuild{data}{tokens}[$i]{"value"}=$teerkobuild{data}{tokens}[$i]{"token"};
            Log3 $teerkobuild{hashdata}{NAME}, 5, $teerkobuild{hashdata}{NAME} . ": +-->+--> Possible Device " . $teerkobuild{data}{tokens}[$i]{"token"};
        }
    }

    return %teerkobuild;
}

sub TEERKO_FailCMD{
    my ($substrarray, %teerkobuild) = @_;
    Log3 $teerkobuild{hashdata}{NAME}, 5, $teerkobuild{hashdata}{NAME} . ": +--> Function for Action '" . $teerkobuild{data}{substrings}[$substrarray]{"action"}{"type"} . "'";
    my $response = $TEERKO_brain{"responsetext"}{"err_nocombination"}[rand @{$TEERKO_brain{"responsetext"}{"err_nocombination"}}];
    my $substrid=$teerkobuild{data}{substrings}[$substrarray]{substrid};
    $response =~ s/%SUBSTRID%/${substrid}/g;
    push(@{$teerkobuild{data}{substrings}[$substrarray]{"responses"}},$response);
    return %teerkobuild;
}

sub TEERKO_RoomDevElimination{
    my ($substrarray, %teerkobuild) = @_;
    
    Log3 $teerkobuild{hashdata}{NAME}, 5, $teerkobuild{hashdata}{NAME} . ": +--> Elimination of all devices that doesnt match to rooms";

    
    my %devcounter =();
    my @roomsels =();
    for(my $i = 0; $i < scalar @{$teerkobuild{data}{substrings}[$substrarray]{"tokens"}};$i++){
        push(@roomsels,$teerkobuild{data}{substrings}[$substrarray]{"tokens"}[$i]{"value"}) 
            if ($teerkobuild{data}{substrings}[$substrarray]{"tokens"}[$i]{"subtype"} eq "room");
        #push(@roomsels,$teerkobuild{data}{substrings}[$substrarray]{"tokens"}[$i]{"value"}) 
        #    if ($teerkobuild{data}{substrings}[$substrarray]{"tokens"}[$i]{"subtype"} eq "lowscoreroom");
    }
    foreach my $roomsel (@roomsels){
        @{$devcounter{lc($roomsel)}}=();
    }
    # Schleifen zur Entfernung von Devices die nicht zu dem Raum passen
    # Zusaetzlich eine Zaehlung um Plural oder Singular fue mehrere Raeume zu unterstuetzen
    TokensLoop: for(my $i = 0; $i < scalar @{$teerkobuild{data}{substrings}[$substrarray]{"tokens"}};$i++){
        if ($teerkobuild{data}{substrings}[$substrarray]{"tokens"}[$i]{"type"} eq "device"){
            foreach my $roomsel (@roomsels){
                @{$devcounter{lc($roomsel)}}=();
            }
            if(scalar @roomsels>0){ #Falls eine Raumangabe erfolgte...
                Log3 $teerkobuild{hashdata}{NAME}, 5, $teerkobuild{hashdata}{NAME} . ": +-->+--> Checking TokenDevice ".$teerkobuild{data}{substrings}[$substrarray]{"tokens"}[$i]{value};
                DevicesLoop: for(my $j = scalar @{$teerkobuild{data}{substrings}[$substrarray]{"tokens"}[$i]{devicelist}} - 1; $j >=0;$j--){
                    RoomsLoop: for(my $k = 0; $k < scalar @{$teerkobuild{data}{substrings}[$substrarray]{"tokens"}[$i]{devicelist}[$j]{rooms}};$k++){
                        if(TEERKO_ValueInArray($teerkobuild{data}{substrings}[$substrarray]{"tokens"}[$i]{devicelist}[$j]{rooms}[$k] =~ s/!//gr, @roomsels)){
                            Log3 $teerkobuild{hashdata}{NAME}, 5, $teerkobuild{hashdata}{NAME} . ": +-->+-->+--> Room vorhanden (". $teerkobuild{data}{substrings}[$substrarray]{"tokens"}[$i]{devicelist}[$j]{rooms}[$k] . "). Device wird aus hash entfernt";
                            push(@{$devcounter{lc($teerkobuild{data}{substrings}[$substrarray]{"tokens"}[$i]{devicelist}[$j]{rooms}[$k] =~ s/!//gr)}},$teerkobuild{data}{substrings}[$substrarray]{"tokens"}[$i]{devicelist}[$j]{name});
                            $teerkobuild{data}{substrings}[$substrarray]{"tokens"}[$i]{devicelist}[$j]{room} = $teerkobuild{data}{substrings}[$substrarray]{"tokens"}[$i]{devicelist}[$j]{rooms}[$k] =~ s/!//gr;
                            if($teerkobuild{data}{substrings}[$substrarray]{"tokens"}[$i]{devicelist}[$j]{rooms}[$k] !~ /\!/g){
                                for(my $l = 0; $l < scalar @{$teerkobuild{data}{substrings}[$substrarray]{"tokens"}[$i]{devicelist}[$j]{rooms}};$l++){
                                    if($teerkobuild{data}{substrings}[$substrarray]{"tokens"}[$i]{devicelist}[$j]{rooms}[$l] =~ /\!/g){
                                        $teerkobuild{data}{substrings}[$substrarray]{"tokens"}[$i]{devicelist}[$j]{room} = $teerkobuild{data}{substrings}[$substrarray]{"tokens"}[$i]{devicelist}[$j]{rooms}[$l] =~ s/!//gr;
                                        last;
                                    }
                                }
                            }
                            next DevicesLoop;
                        }
                    }
                    splice (@{$teerkobuild{data}{substrings}[$substrarray]{"tokens"}[$i]{devicelist}}, $j, 1);
                    Log3 $teerkobuild{hashdata}{NAME}, 5, $teerkobuild{hashdata}{NAME} . ": +-->+-->+--> Room nicht vorhanden. Device wird aus hash entfernt";
                    next DevicesLoop;
                }
                while( my( $key, $value ) = each %devcounter ){
                    if(!$teerkobuild{data}{substrings}[$substrarray]{"tokens"}[$i]{multidevice} && scalar @{$value} >1){
                        EliminationLoop: for(my $j = 0; $j < scalar @{$value};$j++){
                            DevicesLoop: for(my $k = scalar @{$teerkobuild{data}{substrings}[$substrarray]{"tokens"}[$i]{devicelist}} - 1; $k >=0;$k--){
                                #push(@{$teerkobuild{data}{substrings}[$substrarray]{"responses"}},"Ich konnte " . $teerkobuild{data}{substrings}[$substrarray]{"tokens"}[$i]{devicelist}[$k]{alias} . " mehrmals im Raum ".$key."finden.");
                                
                                my $response = $TEERKO_brain{"responsetext"}{"err_singlemultidevice"}[rand @{$TEERKO_brain{"responsetext"}{"err_singlemultidevice"}}];
                                my $aliasreplace = $teerkobuild{data}{substrings}[$substrarray]{"tokens"}[$i]{devicelist}[$k]{alias};
                                my $replacedafp = ReadingsVal($teerkobuild{hashdata}{NAME},".".$aliasreplace . "_dafp","");
                                my $replacedasp = ReadingsVal($teerkobuild{hashdata}{NAME},".".$aliasreplace . "_dasp","");
                                my $replacewith = $teerkobuild{data}{substrings}[$substrarray]{"tokens"}[$i]{devicelist}[$k]{room};
                                my $replacerpp = ReadingsVal($teerkobuild{hashdata}{NAME},".".$replacewith . "_rpp","");
                                $response =~ s/%RPP%/${replacerpp}/g;
                                $response =~ s/%ROOM%/${replacewith}/g;
                                $response =~ s/%DAFP%/${replacedafp}/g;
                                $response =~ s/%DASP%/${replacedasp}/g;
                                $response =~ s/%ALIAS%/${aliasreplace}/g;
                                push(@{$teerkobuild{data}{substrings}[$substrarray]{"responses"}},$response);
                        
                                splice (@{$teerkobuild{data}{substrings}[$substrarray]{"tokens"}[$i]{devicelist}}, $k, 1) if($$value[$j] eq $teerkobuild{data}{substrings}[$substrarray]{"tokens"}[$i]{devicelist}[$k]{name});
                                last DevicesLoop;
                            }
                        }
                    }
                    if(scalar @{$value} ==0){
                        #push(@{$teerkobuild{data}{substrings}[$substrarray]{"responses"}},"Ich konnte " . $teerkobuild{data}{substrings}[$substrarray]{"tokens"}[$i]{value} . "nicht im Raum ".$key."finden.");
                        
                        my $response = $TEERKO_brain{"responsetext"}{"err_deviceroommatchfail"}[rand @{$TEERKO_brain{"responsetext"}{"err_deviceroommatchfail"}}];
                        my $aliasreplace = $teerkobuild{data}{substrings}[$substrarray]{"tokens"}[$i]{value};
                        my $replacedafp = ReadingsVal($teerkobuild{hashdata}{NAME},".".$aliasreplace . "_dafp","");
                        my $replacedasp = ReadingsVal($teerkobuild{hashdata}{NAME},".".$aliasreplace . "_dasp","");
                        my $replacewith = $key;
                        my $replacerpp = ReadingsVal($teerkobuild{hashdata}{NAME},".".$replacewith . "_rpp","");
                        $response =~ s/%RPP%/${replacerpp}/g;
                        $response =~ s/%ROOM%/${replacewith}/g;
                        $response =~ s/%DAFP%/${replacedafp}/g;
                        $response =~ s/%DASP%/${replacedasp}/g;
                        $response =~ s/%ALIAS%/${aliasreplace}/g;
                        push(@{$teerkobuild{data}{substrings}[$substrarray]{"responses"}},$response);
                    }
                }
            }else{
                if(scalar @{$teerkobuild{data}{substrings}[$substrarray]{"tokens"}[$i]{devicelist}}>1 && !$teerkobuild{data}{substrings}[$substrarray]{"tokens"}[$i]{multidevice}){
                    @{$teerkobuild{data}{substrings}[$substrarray]{"tokens"}[$i]{devicelist}}=();
                    my $response = $TEERKO_brain{"responsetext"}{"err_singlemultidevice"}[rand @{$TEERKO_brain{"responsetext"}{"err_singlemultidevice"}}];
                    my $replacewith = $teerkobuild{data}{substrings}[$substrarray]{"tokens"}[$i]{"value"};
                    $response =~ s/%ALIAS%/${replacewith}/g;
                    push(@{$teerkobuild{data}{substrings}[$substrarray]{"responses"}},$response);
                }
            }
        }
    }
    return %teerkobuild;
}

sub TEERKO_ColorValueMod($$$){
    my ($usermaxval, $ismaxval, $convert) = @_;
    Log(3,"***DEBUG*** USERMAXVAL VALUE ".$usermaxval);
    Log(3,"***DEBUG*** ISMAXVAL VALUE ".$ismaxval);
    Log(3,"***DEBUG*** TO CONVERT VALUE ".$convert);
    Log(3,"***DEBUG*** RETURN VALUE ".int(($usermaxval / $ismaxval) * $convert));
    return int(($usermaxval / $ismaxval) * $convert);
}

sub TEERKO_BasicCMD{
    my ($substrarray, %teerkobuild) = @_;
    Log3 $teerkobuild{hashdata}{NAME}, 5, $teerkobuild{hashdata}{NAME} . ": +--> Function for Action '" . $teerkobuild{data}{substrings}[$substrarray]{"action"}{"type"} . "'";
    
    if(AttrVal($teerkobuild{hashdata}{NAME},"TEERKOFeatures","")!~/BasicControl|\-Alle\-/i){
        my $response = $TEERKO_brain{"responsetext"}{"err_feature"}[rand @{$TEERKO_brain{"responsetext"}{"err_feature"}}];
        $response =~ s/%FEATURE%/BasicControl/g;
        push(@{$teerkobuild{"data"}{substrings}[$substrarray]{responses}},$response);
        return %teerkobuild;
    }
    if($teerkobuild{data}{substrings}[$substrarray]{"content"} =~ /subtype:nodevices/i){
        my $response = $TEERKO_brain{"responsetext"}{"err_nodevice"}[rand @{$TEERKO_brain{"responsetext"}{"err_nodevice"}}];
        push(@{$teerkobuild{"data"}{substrings}[$substrarray]{responses}},$response);
        return %teerkobuild;
    }elsif($teerkobuild{data}{substrings}[$substrarray]{"content"} !~ /subtype:device/i){
        my $response = $TEERKO_brain{"responsetext"}{"err_nodevicematch"}[rand @{$TEERKO_brain{"responsetext"}{"err_nodevicematch"}}];
        push(@{$teerkobuild{"data"}{substrings}[$substrarray]{responses}},$response);
        return %teerkobuild;
    }else{
        %teerkobuild = TEERKO_ArticleFinder($substrarray,1,%teerkobuild);
        if($teerkobuild{data}{substrings}[$substrarray]{"content"} =~ /subtype:norooms/i){
            my $response = $TEERKO_brain{"responsetext"}{"err_norooms"}[rand @{$TEERKO_brain{"responsetext"}{"err_norooms"}}];
            push(@{$teerkobuild{"data"}{substrings}[$substrarray]{responses}},$response);
            return %teerkobuild;
        }
        if($teerkobuild{data}{substrings}[$substrarray]{"content"} =~ /subtype:lowscoreroom/i && $teerkobuild{data}{substrings}[$substrarray]{"content"} !~ /subtype:room/i){
            for(my $i = 0; $i < scalar @{$teerkobuild{data}{substrings}[$substrarray]{"tokens"}};$i++){
                if ($teerkobuild{data}{substrings}[$substrarray]{"tokens"}[$i]{"subtype"} eq "lowscoreroom"){
                    my $response = $TEERKO_brain{"responsetext"}{"err_lowscoreroom"}[rand @{$TEERKO_brain{"responsetext"}{"err_lowscoreroom"}}];
                    my $replacewith = $teerkobuild{data}{substrings}[$substrarray]{"tokens"}[$i]{"value"};
                    my $replacerpp = ReadingsVal($teerkobuild{hashdata}{NAME},".".$replacewith . "_rpp","");
                    $response =~ s/%RPP%/${replacerpp}/g;
                    $response =~ s/%ROOM%/${replacewith}/g;
                    push(@{$teerkobuild{data}{substrings}[$substrarray]{"responses"}},$response);
                }
            }
            return %teerkobuild;
        }
        %teerkobuild = TEERKO_RoomDevElimination($substrarray, %teerkobuild);
        for(my $i = 0; $i < scalar @{$teerkobuild{data}{substrings}[$substrarray]{"tokens"}};$i++){
            if ($teerkobuild{data}{substrings}[$substrarray]{"tokens"}[$i]{"subtype"} eq "lowscoredevice"){
                my $response = $TEERKO_brain{"responsetext"}{"err_lowscoredevice"}[rand @{$TEERKO_brain{"responsetext"}{"err_lowscoredevice"}}];
                my $aliasreplace = $teerkobuild{data}{substrings}[$substrarray]{"tokens"}[$i]{"value"};
                my $replacedafp = ReadingsVal($teerkobuild{hashdata}{NAME},".".$aliasreplace . "_dafp","");
                my $replacedasp = ReadingsVal($teerkobuild{hashdata}{NAME},".".$aliasreplace . "_dasp","");
                $response =~ s/%DAFP%/${replacedafp}/g;
                $response =~ s/%DASP%/${replacedasp}/g;
                $response =~ s/%ALIAS%/${aliasreplace}/g;
                push(@{$teerkobuild{data}{substrings}[$substrarray]{"responses"}},$response);
            }
            if ($teerkobuild{data}{substrings}[$substrarray]{"tokens"}[$i]{"subtype"} eq "lowscoreroom"){
                my $response = $TEERKO_brain{"responsetext"}{"err_lowscoreroom"}[rand @{$TEERKO_brain{"responsetext"}{"err_lowscoreroom"}}];
                my $replacewith = $teerkobuild{data}{substrings}[$substrarray]{"tokens"}[$i]{"value"};
                $response =~ s/%ROOM%/${replacewith}/g;
                my $replacerpp = ReadingsVal($teerkobuild{hashdata}{NAME},".".$replacewith . "_rpp","");
                $response =~ s/%RPP%/${replacerpp}/g;
                push(@{$teerkobuild{data}{substrings}[$substrarray]{"responses"}},$response);
            }
        }
        
    }
    return if ($teerkobuild{data}{substrings}[$substrarray]{"content"} !~ /type:device/i);
    for(my $i = 0; $i < scalar @{$teerkobuild{data}{substrings}[$substrarray]{"tokens"}};$i++){
        if($teerkobuild{data}{substrings}[$substrarray]{"tokens"}[$i]{"subtype"} eq "device"){
            DeviceLoop: for(my $j=0; $j<scalar @{$teerkobuild{data}{substrings}[$substrarray]{"tokens"}[$i]{"devicelist"}};$j++){
                my $devname = $teerkobuild{data}{substrings}[$substrarray]{"tokens"}[$i]{"devicelist"}[$j]{"name"};
                my @allowedtocontrol=split(",",AttrVal($teerkobuild{hashdata}{NAME},"TEERKOAllowedToControl",""));
                if(TEERKO_ValueInArray($devname, @allowedtocontrol) || TEERKO_ValueInArray("-Alle-", @allowedtocontrol)){
                    my @teerkoexpertslocal = split(",",AttrVal($devname,"TEERKOExpert",""));
                    my @teerkoexpertsglobal = split(",",AttrVal($teerkobuild{hashdata}{NAME},"TEERKOExpert",""));
                    my @cmdparams = @{$teerkobuild{data}{substrings}[$substrarray]{"action"}{"default_param"}};
                    my $accessexec = 1;
                    $accessexec = 0 if(AttrVal($devname,"TEERKOExpert","")=~/BasicSetRestrictedMapping|AllRestrictedMapping/i or AttrVal($teerkobuild{hashdata}{NAME},"TEERKOExpert","")=~/BasicSetRestrictedMapping|AllRestrictedMapping/i);
                    my $ignorestate ="";
                    my $shortresponse=0;
                    for my $teerkoexpert(@teerkoexpertslocal){
                        my $cmdtype = $teerkobuild{data}{substrings}[$substrarray]{"action"}{"type"};
                        $accessexec = 1 if($teerkoexpert=~/map:${cmdtype}/i);
                        @cmdparams = split(" ",$1) if($teerkoexpert=~/map:${cmdtype}=(.+?)(!|$)/i);
                        $ignorestate =$1 if($teerkoexpert=~/map:${cmdtype}.*!(.*)!/i);
                    }
                    for my $teerkoexpert(@teerkoexpertsglobal){
                        $shortresponse=1 if($teerkoexpert=~/shortresponse/i);
                    }
                    if(!$accessexec){
                        my $response = $TEERKO_brain{"responsetext"}{"err_restrictedmapping"}[rand @{$TEERKO_brain{"responsetext"}{"err_restrictedmapping"}}];
                        $response = $TEERKO_brain{"responsetext"}{"err_restrictedmapping_alias"}[rand @{$TEERKO_brain{"responsetext"}{"err_restrictedmapping_alias"}}]
                            if(exists($TEERKO_brain{"responsetext"}{"err_restrictedmapping_alias"}));
                        $response = $TEERKO_brain{"responsetext"}{"err_restrictedmapping_alias_room"}[rand @{$TEERKO_brain{"responsetext"}{"err_restrictedmapping_alias_room"}}]
                            if(exists($TEERKO_brain{"responsetext"}{"err_restrictedmapping_alias_room"}) && $teerkobuild{data}{substrings}[$substrarray]{"tokens"}[$i]{"devicelist"}[$j]{"room"} ne "");
                        my $aliasreplace = $teerkobuild{data}{substrings}[$substrarray]{"tokens"}[$i]{"devicelist"}[$j]{"alias"};
                        my $roomreplace = $teerkobuild{data}{substrings}[$substrarray]{"tokens"}[$i]{"devicelist"}[$j]{"room"};
                        $response =~ s/%ALIAS%/${aliasreplace}/gi;
                        $response =~ s/%ROOM%/${roomreplace}/gi;
                        push(@{$teerkobuild{data}{substrings}[$substrarray]{"responses"}},$response);
                        next DeviceLoop;
                    }
                    #Suche time wert
                    my $seconds = 0;
                    my $minutes = 0;
                    my $hours = 0;
                    my $addedtime = 0;
                    #my ($sec,$min,$hour,$mday,$month,$year,$wday,$yday,$isdst) =localtime(gettimeofday()+60);
                    if($teerkobuild{data}{substrings}[$substrarray]{"content"} =~ /type:numericvalue:subtype:(hour|minute|second)/){
                        for(my $j = 0; $j < scalar @{$teerkobuild{data}{substrings}[$substrarray]{tokens}};$j++){
                            if($teerkobuild{data}{substrings}[$substrarray]{tokens}[$j]{type} eq "numericvalue" && $teerkobuild{data}{substrings}[$substrarray]{tokens}[$j]{subtype} eq "second"){
                                $addedtime += $teerkobuild{data}{substrings}[$substrarray]{tokens}[$j]{value};
                                $seconds += $teerkobuild{data}{substrings}[$substrarray]{tokens}[$j]{value};
                            }
                            if($teerkobuild{data}{substrings}[$substrarray]{tokens}[$j]{type} eq "numericvalue" && $teerkobuild{data}{substrings}[$substrarray]{tokens}[$j]{subtype} eq "minute"){
                                $addedtime += $teerkobuild{data}{substrings}[$substrarray]{tokens}[$j]{value} * 60;
                                $minutes += $teerkobuild{data}{substrings}[$substrarray]{tokens}[$j]{value};
                            }
                            if($teerkobuild{data}{substrings}[$substrarray]{tokens}[$j]{type} eq "numericvalue" && $teerkobuild{data}{substrings}[$substrarray]{tokens}[$j]{subtype} eq "hour"){
                                $addedtime += $teerkobuild{data}{substrings}[$substrarray]{tokens}[$j]{value} * 60 * 60;
                                $hours += $teerkobuild{data}{substrings}[$substrarray]{tokens}[$j]{value};
                            }
                        }
                    }
                    #Suche pct wert
                    my $normalintval = -1;
                    if($teerkobuild{data}{substrings}[$substrarray]{"action"}{"type"} eq "setpct"){
                        for(my $k = 0; $k < scalar @{$teerkobuild{data}{substrings}[$substrarray]{"tokens"}};$k++){
                            if($teerkobuild{data}{substrings}[$substrarray]{"tokens"}[$k]{"type"} eq "numericvalue" && $teerkobuild{data}{substrings}[$substrarray]{"tokens"}[$k]{"subtype"} eq "normal"){
                                $normalintval=$teerkobuild{data}{substrings}[$substrarray]{"tokens"}[$k]{"value"};
                                last;
                            }
                        }
                    }
                    #Suche color wert
                    my $coloren = "none";
                    my $colorde = "none";
                    my $colorhex = "none";
                    my $colorrgb ="";
                    my $colorrgb1 ="";
                    my $colorrgb2 ="";
                    my $colorrgb3 ="";
                    my $colorhsv ="";
                    my $colorhsv1 ="";
                    my $colorhsv2 ="";
                    my $colorhsv3 ="";
                    if($teerkobuild{data}{substrings}[$substrarray]{"action"}{"type"} eq "setcolor"){
                        for(my $j = 0; $j < scalar @{$teerkobuild{data}{substrings}[$substrarray]{"tokens"}};$j++){
                            if($teerkobuild{data}{substrings}[$substrarray]{"tokens"}[$j]{"type"} eq "colortable"){
                                #en:yellow;de:Gelb;hex:ffff00
                                ($coloren,$colorde,$colorhex)=($teerkobuild{data}{substrings}[$substrarray]{"tokens"}[$j]{"subtype"}=~/en:(.*?);de:(.*?);hex:(.*)/g);
                                my @colorrgbarray = Color::hex2rgb($colorhex);
                                $colorrgb = $colorrgbarray[0] . "," . $colorrgbarray[1] . "," . $colorrgbarray[2];
                                $colorrgb1 = $colorrgbarray[0];
                                $colorrgb2 = $colorrgbarray[1];
                                $colorrgb3 = $colorrgbarray[2];
                                my @colorhsvarray = Color::hex2hsv($colorhex);
                                Log(3,"***DEBUG*** HSV1 ".$colorhsvarray[0]);
                                Log(3,"***DEBUG*** HSV2 ".$colorhsvarray[1]);
                                Log(3,"***DEBUG*** HSV3 ".$colorhsvarray[2]);
                                $colorhsv = int(360*$colorhsvarray[0]) . "," . int(360*$colorhsvarray[1]) . "," . int(360*$colorhsvarray[2]);
                                $colorhsv1 = 360*$colorhsvarray[0];
                                $colorhsv2 = 100*$colorhsvarray[1];
                                $colorhsv3 = 100*$colorhsvarray[2];
                                last;
                            }
                        }
                    }
                    for my $default_param(@cmdparams){
                        $default_param =~ s/%INT%/${normalintval}/gi;
                        $default_param =~ s/%CEN%/${coloren}/gi;
                        $default_param =~ s/%CDE%/${colorde}/gi;
                        $default_param =~ s/%CRGB%/${colorrgb}/gi;
                        $default_param =~ s/%CRGB1%/${colorrgb1}/gi;
                        $default_param =~ s/%CRGB2%/${colorrgb2}/gi;
                        $default_param =~ s/%CRGB3%/${colorrgb3}/gi;
                        $default_param =~ s/%CHSV%/${colorhsv}/gi;
                        $default_param =~ s/%CHSV1%/${colorhsv1}/gi;
                        $default_param =~ s/%CHSV2%/${colorhsv2}/gi;
                        $default_param =~ s/%CHSV3%/${colorhsv3}/gi;
                        $default_param =~ s/%CHEX%/${colorhex}/gi;
                        
                        if($default_param =~ /%C(RGB|HSV)(1|2|3)_(\d+)%/){
                            my $type=$1;
                            my $range=int($2);
                            my $usermax=int($3);
                            Log3 $teerkobuild{hashdata}{NAME}, 5, $teerkobuild{hashdata}{NAME} . ": +--> TYPE " . $type. " RANGE " . $range. " USERMAX " . $usermax. " ";
                            if($type =~/rgb/i){
                                if($usermax<255){
                                    my $convertvalue =0;
                                    $convertvalue = TEERKO_ColorValueMod($usermax,255,$colorrgb1) if($range==1);
                                    $convertvalue = TEERKO_ColorValueMod($usermax,255,$colorrgb2) if($range==2);
                                    $convertvalue = TEERKO_ColorValueMod($usermax,255,$colorrgb3) if($range==3);
                                    $default_param =~ s/%C${type}${range}_${usermax}%/${convertvalue}/gi;
                                }
                            }
                            if($type =~/hsv/i){
                                if($usermax<360){
                                    my $convertvalue =0;
                                    $convertvalue = TEERKO_ColorValueMod($usermax,360,$colorhsv1) if($range==1);
                                    $convertvalue = TEERKO_ColorValueMod($usermax,100,$colorhsv2) if($range==2);
                                    $convertvalue = TEERKO_ColorValueMod($usermax,100,$colorhsv3) if($range==3);
                                    $default_param =~ s/%C${type}${range}_${usermax}%/${convertvalue}/gi;
                                }
                            }
                        }
                    }
                    if(Value($devname) ne $ignorestate){
                        my $sleeper ="";
                        $sleeper = "sleep $addedtime;" if($addedtime>0);
                        push(@{$teerkobuild{data}{substrings}[$substrarray]{"fhemcommands"}},$sleeper . "set ". $teerkobuild{data}{substrings}[$substrarray]{"tokens"}[$i]{"devicelist"}[$j]{"name"} ." ".join(" ",@cmdparams)) ;
                        if($shortresponse){
                            push(@{$teerkobuild{data}{substrings}[$substrarray]{"responses"}},"Ok. ") if(!TEERKO_ValueInArray("Ok. ", @{$teerkobuild{data}{substrings}[$substrarray]{"responses"}}));
                        }else{
                            my $response = "Ok. ";
                            $response = $teerkobuild{data}{substrings}[$substrarray]{action}{response}{normal_success}[rand @{$teerkobuild{data}{substrings}[$substrarray]{action}{response}{normal_success}}]
                                if(exists($teerkobuild{data}{substrings}[$substrarray]{action}{response}{normal_success}));
                            $response = $teerkobuild{data}{substrings}[$substrarray]{action}{response}{normal_success_sleep}[rand @{$teerkobuild{data}{substrings}[$substrarray]{action}{response}{normal_success_sleep}}]
                                if(exists($teerkobuild{data}{substrings}[$substrarray]{action}{response}{normal_success_sleep}) && $addedtime>0);
                            if($teerkobuild{data}{substrings}[$substrarray]{"tokens"}[$i]{"devicelist"}[$j]{"room"} ne ""){
                                $response = $teerkobuild{data}{substrings}[$substrarray]{action}{response}{normal_success_room}[rand @{$teerkobuild{data}{substrings}[$substrarray]{action}{response}{normal_success_room}}]
                                    if(exists($teerkobuild{data}{substrings}[$substrarray]{action}{response}{normal_success_room}));
                                $response = $teerkobuild{data}{substrings}[$substrarray]{action}{response}{normal_success_room_sleep}[rand @{$teerkobuild{data}{substrings}[$substrarray]{action}{response}{normal_success_room_sleep}}]
                                    if(exists($teerkobuild{data}{substrings}[$substrarray]{action}{response}{normal_success_room_sleep}) && $addedtime>0);
                            }
                            my $aliasreplace = $teerkobuild{data}{substrings}[$substrarray]{"tokens"}[$i]{"devicelist"}[$j]{"alias"};
                            my $roomreplace = $teerkobuild{data}{substrings}[$substrarray]{"tokens"}[$i]{"devicelist"}[$j]{"room"};
                            my $replacedafp = ReadingsVal($teerkobuild{hashdata}{NAME},".".$aliasreplace . "_dafp","");
                            my $replacedasp = ReadingsVal($teerkobuild{hashdata}{NAME},".".$aliasreplace . "_dasp","");
                            my $replacerpp = ReadingsVal($teerkobuild{hashdata}{NAME},".".$roomreplace . "_rpp","");
                            $response =~ s/%RPP%/${replacerpp}/g;
                            
                            my $sleepreplace = "";
                            if($addedtime>0 && $sleepreplace eq "" && $hours > 0){
                                $sleepreplace .= " ". $hours . " Stunden"  ;
                            }elsif($addedtime>0 && $sleepreplace ne "" && $hours > 0){
                                $sleepreplace .= " und ". $hours . " Stunden";
                            }
                            if($addedtime>0 && $sleepreplace eq "" && $minutes > 0){
                                $sleepreplace .= " ". $minutes . " Minuten"  ;
                            }elsif($addedtime>0 && $sleepreplace ne "" && $minutes > 0){
                                $sleepreplace .= " und ". $minutes . " Minuten";
                            }
                            if($addedtime>0 && $sleepreplace eq "" && $seconds > 0){
                                $sleepreplace .= " ". $seconds . " Sekunden"  ;
                            }elsif($addedtime>0 && $sleepreplace ne "" && $seconds > 0){
                                $sleepreplace .= " und ". $seconds . " Sekunden";
                            }
                            $sleepreplace = " in".$sleepreplace;
                            
                            $response =~ s/%ALIAS%/${aliasreplace}/gi;
                            $response =~ s/%DAFP%/${replacedafp}/g;
                            $response =~ s/%DASP%/${replacedasp}/g;
                            $response =~ s/%ROOM%/${roomreplace}/gi;
                            $response =~ s/%INT%/${normalintval}/g;
                            $response =~ s/%CEN%/${coloren}/g;
                            $response =~ s/%CDE%/${colorde}/g;
                            $response =~ s/%CRGB%/${colorrgb}/g;
                            $response =~ s/%CHEX%/${colorhex}/g;
                            $response =~ s/%SLEEP%/${sleepreplace}/g;
                            push(@{$teerkobuild{data}{substrings}[$substrarray]{"responses"}},$response);
                        }
                    }else{
                        push(@{$teerkobuild{data}{substrings}[$substrarray]{"responses"}},"Ok. ") if(!TEERKO_ValueInArray("Ok. ", @{$teerkobuild{data}{substrings}[$substrarray]{"responses"}}));
                    }
                }else{
                    my $response = $TEERKO_brain{"responsetext"}{"err_noright"}[rand @{$TEERKO_brain{"responsetext"}{"err_noright"}}];
                    my $aliasreplace = $teerkobuild{data}{substrings}[$substrarray]{"tokens"}[$i]{"devicelist"}[$j]{"alias"};
                    my $roomreplace = $teerkobuild{data}{substrings}[$substrarray]{"tokens"}[$i]{"devicelist"}[$j]{"room"};
                    $response =~ s/%ALIAS%/${aliasreplace}/gi;
                    $response =~ s/%ROOM%/${roomreplace}/gi;
                    push(@{$teerkobuild{data}{substrings}[$substrarray]{"responses"}},$response);
                }
            }
        }
    }
    return %teerkobuild;
    
}

sub TEERKO_GetState{
    my ($substrarray, %teerkobuild) = @_;
    Log3 $teerkobuild{hashdata}{NAME}, 5, $teerkobuild{hashdata}{NAME} . ": +--> Function for Action '" . $teerkobuild{data}{substrings}[$substrarray]{"action"}{"type"} . "'";
    
    if(AttrVal($teerkobuild{hashdata}{NAME},"TEERKOFeatures","")!~/BasicControl|\-Alle\-/i){
        my $response = $TEERKO_brain{"responsetext"}{"err_feature"}[rand @{$TEERKO_brain{"responsetext"}{"err_feature"}}];
        $response =~ s/%FEATURE%/BasicControl/g;
        push(@{$teerkobuild{"data"}{substrings}[$substrarray]{responses}},$response);
        return %teerkobuild;
    }
    if($teerkobuild{data}{substrings}[$substrarray]{"content"} =~ /subtype:nodevices/i){
        my $response = $TEERKO_brain{"responsetext"}{"err_nodevice"}[rand @{$TEERKO_brain{"responsetext"}{"err_nodevice"}}];
        push(@{$teerkobuild{"data"}{substrings}[$substrarray]{responses}},$response);
        return %teerkobuild;
    }elsif($teerkobuild{data}{substrings}[$substrarray]{"content"} !~ /subtype:device/i){
        my $response = $TEERKO_brain{"responsetext"}{"err_nodevicematch"}[rand @{$TEERKO_brain{"responsetext"}{"err_nodevicematch"}}];
        push(@{$teerkobuild{"data"}{substrings}[$substrarray]{responses}},$response);
        return %teerkobuild;
    }else{
        %teerkobuild = TEERKO_ArticleFinder($substrarray,2,%teerkobuild);
        if($teerkobuild{data}{substrings}[$substrarray]{"content"} =~ /subtype:norooms/i){
            my $response = $TEERKO_brain{"responsetext"}{"err_norooms"}[rand @{$TEERKO_brain{"responsetext"}{"err_norooms"}}];
            push(@{$teerkobuild{"data"}{substrings}[$substrarray]{responses}},$response);
            return %teerkobuild;
        }
        if($teerkobuild{data}{substrings}[$substrarray]{"content"} =~ /subtype:lowscoreroom/i && $teerkobuild{data}{substrings}[$substrarray]{"content"} !~ /subtype:room/i){
            for(my $i = 0; $i < scalar @{$teerkobuild{data}{substrings}[$substrarray]{"tokens"}};$i++){
                if ($teerkobuild{data}{substrings}[$substrarray]{"tokens"}[$i]{"subtype"} eq "lowscoreroom"){
                    my $response = $TEERKO_brain{"responsetext"}{"err_lowscoreroom"}[rand @{$TEERKO_brain{"responsetext"}{"err_lowscoreroom"}}];
                    my $replacewith = $teerkobuild{data}{substrings}[$substrarray]{"tokens"}[$i]{"value"};
                    my $replacerpp = ReadingsVal($teerkobuild{hashdata}{NAME},".".$replacewith . "_rpp","");
                    $response =~ s/%RPP%/${replacerpp}/g;
                    $response =~ s/%ROOM%/${replacewith}/g;
                    push(@{$teerkobuild{data}{substrings}[$substrarray]{"responses"}},$response);
                }
            }
            return %teerkobuild;
        }
        %teerkobuild = TEERKO_RoomDevElimination($substrarray, %teerkobuild);
        for(my $i = 0; $i < scalar @{$teerkobuild{data}{substrings}[$substrarray]{"tokens"}};$i++){
            if ($teerkobuild{data}{substrings}[$substrarray]{"tokens"}[$i]{"subtype"} eq "lowscoredevice"){
                my $response = $TEERKO_brain{"responsetext"}{"err_lowscoredevice"}[rand @{$TEERKO_brain{"responsetext"}{"err_lowscoredevice"}}];
                my $aliasreplace = $teerkobuild{data}{substrings}[$substrarray]{"tokens"}[$i]{"value"};
                my $replacedafp = ReadingsVal($teerkobuild{hashdata}{NAME},".".$aliasreplace . "_dafp","");
                my $replacedasp = ReadingsVal($teerkobuild{hashdata}{NAME},".".$aliasreplace . "_dasp","");
                $response =~ s/%DAFP%/${replacedafp}/g;
                $response =~ s/%DASP%/${replacedasp}/g;
                $response =~ s/%ALIAS%/${aliasreplace}/g;
                
                push(@{$teerkobuild{data}{substrings}[$substrarray]{"responses"}},$response);
            }
            if ($teerkobuild{data}{substrings}[$substrarray]{"tokens"}[$i]{"subtype"} eq "lowscoreroom"){
                my $response = $TEERKO_brain{"responsetext"}{"err_lowscoreroom"}[rand @{$TEERKO_brain{"responsetext"}{"err_lowscoreroom"}}];
                my $replacewith = $teerkobuild{data}{substrings}[$substrarray]{"tokens"}[$i]{"value"};
                my $replacerpp = ReadingsVal($teerkobuild{hashdata}{NAME},".".$replacewith . "_rpp","");
                $response =~ s/%RPP%/${replacerpp}/g;
                $response =~ s/%ROOM%/${replacewith}/g;
                push(@{$teerkobuild{data}{substrings}[$substrarray]{"responses"}},$response);
            }
        }
        
    }
    return if ($teerkobuild{data}{substrings}[$substrarray]{"content"} !~ /type:device/i);
    for(my $i = 0; $i < scalar @{$teerkobuild{data}{substrings}[$substrarray]{"tokens"}};$i++){
        if($teerkobuild{data}{substrings}[$substrarray]{"tokens"}[$i]{"subtype"} eq "device"){
            DeviceLoop: for(my $j=0; $j<scalar @{$teerkobuild{data}{substrings}[$substrarray]{"tokens"}[$i]{"devicelist"}};$j++){
                my $devname = $teerkobuild{data}{substrings}[$substrarray]{"tokens"}[$i]{"devicelist"}[$j]{"name"};
                my @teerkoexpertslocal = split(",",AttrVal($devname,"TEERKOExpert",""));
                my @teerkoexpertsglobal = split(",",AttrVal($teerkobuild{hashdata}{NAME},"TEERKOExpert",""));
                my @cmdparams = @{$teerkobuild{data}{substrings}[$substrarray]{"action"}{"default_param"}};
                my @sarslocal=();
                my $accessexec = 1;
                $accessexec = 0 if(AttrVal($devname,"TEERKOExpert","")=~/BasicGetRestrictedMapping|AllRestrictedMapping/i or AttrVal($teerkobuild{hashdata}{NAME},"TEERKOExpert","")=~/BasicGetRestrictedMapping|AllRestrictedMapping/i);
                for my $teerkoexpert(@teerkoexpertslocal){
                    my $cmdtype = $teerkobuild{data}{substrings}[$substrarray]{"action"}{"type"};
                    $accessexec = 1 if($teerkoexpert=~/map:${cmdtype}/i);
                    @cmdparams = split(" ",$1) if($teerkoexpert=~/map:${cmdtype}=(.+?)(%|$)/i);
                    push(@sarslocal,$1) if($teerkoexpert=~/sar:(.+?)(%|$)/i);
                }
                for my $teerkoexpert(@teerkoexpertsglobal){
                    #push(@sarsglobal,$1) if($teerkoexpert=~/sar:(.+?)(%|$)/i);
                }
                if(!$accessexec){
                    my $response = $TEERKO_brain{"responsetext"}{"err_restrictedmapping"}[rand @{$TEERKO_brain{"responsetext"}{"err_restrictedmapping"}}];
                    $response = $TEERKO_brain{"responsetext"}{"err_restrictedmapping_alias"}[rand @{$TEERKO_brain{"responsetext"}{"err_restrictedmapping_alias"}}]
                        if(exists($TEERKO_brain{"responsetext"}{"err_restrictedmapping_alias"}));
                    $response = $TEERKO_brain{"responsetext"}{"err_restrictedmapping_alias_room"}[rand @{$TEERKO_brain{"responsetext"}{"err_restrictedmapping_alias_room"}}]
                        if(exists($TEERKO_brain{"responsetext"}{"err_restrictedmapping_alias_room"}) && $teerkobuild{data}{substrings}[$substrarray]{"tokens"}[$i]{"devicelist"}[$j]{"room"} ne "");
                    my $aliasreplace = $teerkobuild{data}{substrings}[$substrarray]{"tokens"}[$i]{"devicelist"}[$j]{"alias"};
                    my $roomreplace = $teerkobuild{data}{substrings}[$substrarray]{"tokens"}[$i]{"devicelist"}[$j]{"room"};
                    $response =~ s/%ALIAS%/${aliasreplace}/gi;
                    $response =~ s/%ROOM%/${roomreplace}/gi;
                    push(@{$teerkobuild{data}{substrings}[$substrarray]{"responses"}},$response);
                    next DeviceLoop;
                }                
                
                my $response = $teerkobuild{data}{substrings}[$substrarray]{action}{response}{normal_success}[rand @{$teerkobuild{data}{substrings}[$substrarray]{action}{response}{normal_success}}];
                if($teerkobuild{data}{substrings}[$substrarray]{"tokens"}[$i]{"devicelist"}[$j]{"room"} ne ""){
                    $response = $teerkobuild{data}{substrings}[$substrarray]{action}{response}{normal_success_room}[rand @{$teerkobuild{data}{substrings}[$substrarray]{action}{response}{normal_success_room}}]
                        if(exists($teerkobuild{data}{substrings}[$substrarray]{action}{response}{normal_success_room}));
                }

                my $aliasreplace = $teerkobuild{data}{substrings}[$substrarray]{"tokens"}[$i]{"devicelist"}[$j]{"alias"};
                my $roomreplace = $teerkobuild{data}{substrings}[$substrarray]{"tokens"}[$i]{"devicelist"}[$j]{"room"};
                my $stateresult=ReadingsVal($devname,join(" ",@cmdparams),"Unbekannt");
                my $replacedafp = ReadingsVal($teerkobuild{hashdata}{NAME},".".$aliasreplace . "_dafp","");
                my $replacedasp = ReadingsVal($teerkobuild{hashdata}{NAME},".".$aliasreplace . "_dasp","");
                my $replacerpp = ReadingsVal($teerkobuild{hashdata}{NAME},".".$roomreplace . "_rpp","");
                $response =~ s/%RPP%/${replacerpp}/g;
                $response =~ s/%DAFP%/${replacedafp}/g;
                $response =~ s/%DASP%/${replacedasp}/g;
                $response =~ s/%ALIAS%/$aliasreplace/g;
                $response =~ s/%STATE%/!${stateresult}!/g;
                $response =~ s/%ROOM%/${roomreplace}/gi;
                for my $sarlocal(@sarslocal){
                    if($sarlocal=~ /(.*)=(.*)/i){
                        my $search=$1;
                        my $replace=$2;
                        $response =~ s/\!${search}\!/${replace}/ig;
                    }
                }
                
                push(@{$teerkobuild{data}{substrings}[$substrarray]{"responses"}},$response);

            }
        }
    }
    return %teerkobuild;
    
    
}

1;

=pod
=item summary Controls fhem with textprocessing with other moduls
=item summary_DE kontrolliert fhem mit textauswertungen

=begin html

<a name="TEERKO"></a>
<h3>TEERKO</h3>
<ul>
    TEERKO is for Text Processing. You can put normal Text local on the device,
    it can detect Text from an TelegramAccount (TelegramBot required) or
    Voice To Text Input by an AMAD Device (AMAD required).
    For a detailed Description see <a href="commandref_DE.html#TEERKO">german section</a>.
    
</ul>

=end html
=begin html_DE

<a name="TEERKO"></a>
<h3>TEERKO</h3>
<ul>
    <li><a href="#TEERKOintro">Einleitung</a></li>
    <li><a href="#TEERKOdefine">Define</a></li>
    <li><a href="#TEERKOset">Set</a></li>
    <li><a href="#TEERKOget">Get</a></li>
    <li><a href="#TEERKOattr">Attr</a></li>
    <ul>
    <li><a href="#TEERKOteerkoattr">TEERKO Devices spezifische Attr</a></li>
    <li><a href="#TEERKOotherattr">Devices spezifische Attr</a></li>
    </ul>
    <li><a href="#TEERKOuserdef">Benutzerdefinierte Befehle</a></li>
    <ul>
        <li><a href="#TEERKOuserdefstructure">Aufbau der Datei</a></li>
    </ul>
</ul>
<ul>
    <a name="TEERKOintro"></a>
    <b>Einleitung</b><br>
    TEERKO ist für TextProcessing innerhalb von FHEM verantwortlich. Textbefehle
    können entweder direkt im Modul eingegeben werden oder von TEERKO automatisch
    in anderen Modulen erkannt werden. Erkannt wird derzeit z.B. von einem 
    Telegram Device (Modul 50_TelegramBot.pm) oder per Spracheingabe durch 
    ein AMAD Device (Modul 50_TelegramBot.pm).
    Das Modul TEERKO sucht nach den Befehlen und entscheidet was es tun soll.<br>
    <br>
    Beispielsätze:<br>
    <i>Schalte die Deckenlampe im Schlafzimmer aus</i><br>
    <i>Fahre das Rollo im Wohnzimmer runter</i><br>
    <i>Schalte alle Lampen im Erdgeschoss aus</i><br>
    <br>
    <a name="TEERKOdefine"></a>
    <b>Define</b>
    <ul>
        <code>define &lt;name&gt; TEERKO</code>
        <br><br>
        Anlegen des Devices
        <br>
    </ul>
    <br>
    <a name="TEERKOset"></a>
    <b>Set</b>
    <ul>
        <code>set &lt;name&gt; TextCommand &lt;command&gt;</code>
        <ul>
            Lokal eingegebenes Kommando. Bitte darauf achten Befehle in
            natürlicher Sprache zu halten. Besonders Wichtig ist die Angabe
            einer Präposition für die Raumerkennung:<br>
            <code>Dimme die Stehlampe im Wohnzimmer auf 30%</code><br>
            and not<br>
            <code>Stehlampe Wohnzimmer 30</code>
        </ul><br>
        <code>set &lt;name&gt; AMADAnswer [msg|tts|extern]</code>
        <ul>
            Auf welche Art soll bei einer Anfrage über das AMAD Device
            geantwortet werden.<br>
        </ul><br>
        <code>set &lt;name&gt; ReadUserFile [full path to file]</code>
        <ul>
            Benutzerdefinierte Befehle werden aus der Datei eingelesen und dem
            Modul zur Verfügung gestellt. Die Pfadangabe muss nicht erfolgen 
            wenn der Pfad im Attribut "TEERKOUserDefFile" abgelegt ist.<br>
            <a>Datei für Benutzerdefinierte Befehle anlegen</a>.
        </ul><br>
        <code>set &lt;name&gt; ExternalResponse [Select Devices]</code>
        <ul>
            Hier können zusätzliche Geräte angelegt werden an denen eine Ausgabe
            erfolgt, wenn zum Beispiel automatische Meldungen generiert werden
            oder die Anfrage per AMAD kommt. Mögliche zusätzliche Ausgabedevices
            sind derzeit: 70_Pushover.pm, 70_KODI.pm, 21_SONOSPLAYER.pm, 
            98_Text2Speech.pm
        </ul><br>
        <code>set &lt;name&gt; UpdateLists</code>
        <ul>
            Aktualisieren der Auswahlfelder für Bsp. ExternalResonses oder das 
            Attribut TEERKOAllowedtoControl
        </ul><br>
    </ul>
    <br>
    <a name="TEERKOget"></a>
    <b>Get</b>
    <ul>
    <code>get &lt;name&gt; Information</code>
        <ul>
            Listet alle Teerko Räume und Devices auf. Achtung! Es werden 
            wirklich nur diese angezeigt wo die Attribute über TEERKO gesetzt
            werden. Teerko reagiert trotzdem noch auf die normalen aliase.
        </ul><br>
    </ul>
    <br>
    <a name="TEERKOattr"></a>
    <a name="TEERKOteerkoattr"></a>
    <b>TEERKO Devices spezifische Attr</b>
    <ul>
        <code>attr &lt;name&gt; TEERKOAllowedToControl &lt;DeviceNames&gt;</code>
        <ul>
            Hier werden alle Geräte angeben die geschaltet werden dürfen. 
            Dieses Attribut ist als Sicherheitsvorkehrung gedacht damit bei einer
            Missinterpretation des Befehls nicht die falschen Devices geschaltet
            werden. Es ist möglich auch "-Alle-" zu wählen. Somit ist ein schalten
            für jedes Gerät möglich.
        </ul><br>
        <code>attr &lt;name&gt; TEERKOFeatures [Select Features]</code>
        <ul>
            <li><i>-Alle-</i><br>
            Alle Features werden für das TEERKO Device freigeschaltet</li>
            <li><i>InformLowBattery</i><br>
            Die automatische Warnmeldung für Batterien wird freigeschaltet.
            Sofern eine Batteriemeldung erkannt wird, sendet Teerko diese an
            alle angegebenen Geräte inkl. derer die unter ExternalResponse
            angegeben sind.</li>
            <li><i>BasicControl</i><br>
            Die Basisbefehle werden freigeschaltet. Status abfragen, an- und
            ausschalten ...</li>
            <li><i>UserDefindeCommands</i><br>
            Das nutzen der Benutzerdefinierten Befehle wird freigeschaltet</li>
            <li><i>InformFHEMActions</i><br>
            Wenn FHEM Aktionen ausgeführt werden (rename device o.ä) die
            ein TEERKO Device irgendwie berühren wird eine Meldung ausgegeben</li>
        </ul><br>
        <code>attr &lt;name&gt; TEERKOHotword [Komma getrennte Hotwords]</code>
        <ul>
            Sollte nicht wenigstens eines der eingetragenen Hotwords auf den 
            Befehl passen wird das TEERKO Device das Kommando verwerfen und nicht
            reagieren
        </ul><br>
        <code>attr &lt;name&gt; TEERKOTelegramDevice [Select TelegramDevices]</code>
        <ul>
            Angabe der Telegram Devices auf welchen "gelauscht" werden soll.
        </ul><br>
        <code>attr &lt;name&gt; TEERKOTelegramPeerId [Select TelegramAccounts]</code>
        <ul>
            Auswahl der Accounts auf welche reagiert werden soll
        </ul><br>
        <code>attr &lt;name&gt; TEERKOAMADDevice [Select AMADDevices]</code>
        <ul>
            Angabe der AMAD Devices auf welchen "gelauscht" werden soll.
        </ul><br>
        <code>attr &lt;name&gt; TEERKOExpert [Komma getrennte Experteneingaben]</code>
        <ul>
            Mit dem Attribut TEERKOExpert kann das verhalten und die Auswirkung 
            von einem TEERKODevice auf alle anderen Devices stark verändert werden.<br>
            Die spezifischen Verhaltensbefehle werden Komma separiert eingetragen.
            Es gibt derzeit 2 Arten:
            <ul>
                <li><b><u>Search an Replace befehle:</u></b><br>
                <b>Aufbau:</b>
                <ul>
                    <li><i>sar:&lt;search&gt;=&lt;replace&gt;</i></li>
                </ul>
                <b>Erklärung:</b><br>
                Beim auslesen, z.b. beim Aktionstypen <i>getstate</i>, werden
                meist englische Werte ausgegeben oder solche die nicht "toll"
                aussehen. Mit dem sar Wert kann ein solches Reading ersetzt
                werden. Dieses Ersetzen findet dann bei allen Devices statt,
                sofern das Reading nicht bereits mit dem selben Attribut im
                betroffenen Device ersetzt wurde<br>
                <b>Beispiele:</b><br>
                <ul>
                    <li><i>sar:on=an,sar:off=aus</i><br>
                        Readingergebnisse welche <i>on</i> sind werden durch 
                        <i>an</i> ersetzt.
                        <i>off</i> wird duch <i>aus</i> ersetzt.<br>
                        Sollte in einem Device <i>on</i> für etwas anderes stehen
                        kann der Befehl sar auch in dem betroffenen Device
                        gesetzt werden.
                </ul>
            </ul>
            <ul>
                <li><b><u>Sonstige befehle:</u></b><br>
                <ul>
                    <li><i>AllRestrictedMapping</i><br>
                        Wenn der Befehl in dem TEERKO Device gesetzt wird, kann
                        dieses TEERKO ausschließlich die Geräte mit dem Befehl
                        schalten oder abfragen in denen dieses auch gemappt ist. 
                        Siehe dazu 
                        bitte <i>Devices spezifische Attr-&gt;TEERKOExpert</i>
                    <li><i>BasicSetRestrictedMapping</i><br>
                        Gleiches wie  AllRestrictedMapping mit dem Unterschied das
                        Die Basisbefehle begrenzt werden auf jene welche in den 
                        Devices gemappt sind</li>
                    <li><i>BasicGetRestrictedMapping</i><br>
                        Gleiches wie  AllRestrictedMapping mit dem Unterschied das
                        Die Get State begrenzt werden auf jene welche in den 
                        Devices gemappt sind</li>
                    <li><i>shortresponse</i><br>
                        Die Antworten sind nicht immer sonderlich Interessant.
                        Wenn man nicht immer alle Aktionen bestätigt haben will
                        wenn man ein Device schaltet, kann man diesen Befehl 
                        setzen. Alle Auszuführenden Aktionen werden nur mit der
                        Antwort <i>Ok</i> zusammengefasst.</i>
                </ul>
            </ul>
        </ul><br>
    </ul>
    <a name="TEERKOotherattr"></a>
    <b>Devices spezifische Attr</b>
    <ul>
        <code>attr &lt;name&gt; TEERKOAlias [Komma getrennte Aliase]</code>
        <ul>
            Angabe aller Aliase unter welchen das Device zu finden ist.
            Favoriten werden mit einem ! vorangestellt.<br>
            Bsp: attr &lt;name&gt; TEERKOAlias Lampe,!Deckenlampe,Licht
        </ul><br>
        <code>attr &lt;name&gt; TEERKORoom [Komma getrennte Rooms]</code>
        <ul>
            Angabe aller Rooms unter welchen das Device zu finden ist.
            Favoriten werden mit einem ! vorangestellt.<br>
            Bsp: attr &lt;name&gt; TEERKORoom !Wohnzimmer,Ergeschoss,Haus
        </ul><br>
        <code>attr &lt;name&gt; TEERKOExpert [Komma getrennte Experteneingaben]</code>
        <ul>
            Mit dem Attribut TEERKOExpert kann das verhalten und die Auswirkung 
            von einem TEERKODevice auf ein anderes Device stark verändert werden.<br>
            Die spezifischen Verhaltensbefehle werden Komma separiert eingetragen.
            Es gibt derzeit 3 Arten:
            <ul>
                <li><b><u>Mapping befehle:</u></b><br>
                <b>Aufbau:</b>
                <ul>
                    <li>Typ 1 <i>map:&lt;type&gt;</i></li>
                    <li>Typ 2 <i>map:&lt;type&gt=&lt;cmd&gt</i></li>
                    <li>Typ 3 <i>map:&lt;type&gt%&lt;!ignorestate!</i></li>
                    <li>Typ 4 <i>map:&lt;type&gt=&lt;cmd&gt%&lt;!ignorestate&gt%!</i></li>
                </ul>
                <b>Erklärung:</b><br>
                Jede Aktion die ausgeführt wird hat einen Aktionstypen.
                Mit dem Mapping Kommando kann man die Aktion beeinflussen.
                &lt;type&gt gibt diesen Aktionstypen an. Mit &lt;cmd&gt überschreibt man
                die default Aktionen die in TEERKO hinterlegt sind. Mit
                &lt;ignorestate&gt wird ein Kommando ignoriert wenn das Device diesen
                Status schon hat.<br><br>
                Folgende Aktionstypen sind derzeit verfügbar:<br>
                seton,setoff,setup,setdown,setopen,setclose,setpct,setcolor,getstate
                <b>Beispiele:</b><br>
                <ul>
                    <li><i>map:seton=pct 100!on!</i><br>
                        Das Gerät führt zum Beispiel bei dem Befehl <i>Schalte
                        die Stehlampe im Wohnzimmer an</i> den FHEM Befehl <i>
                        set <device> pct 100</i> aus. Aber auch nur wenn der 
                        aktuelle Status <u>nicht</u> <i>on</i> ist</li>
                    <li><i>map:getstate=reading</i><br>
                        Das Gerät gibt zum Beispiel bei dem Befehl <i>Wie ist 
                        der Status der Haustür</i> nicht das Reading <i>state</i>
                        zurück sondern das des angegeben readings</li>
                </ul>
            </ul>
            <ul>
                <li><b><u>Search an Replace befehle:</u></b><br>
                <b>Aufbau:</b>
                <ul>
                    <li><i>sar:&lt;search&gt;=&lt;replace&gt;</i></li>
                </ul>
                <b>Erklärung:</b><br>
                Beim auslesen, z.b. beim Aktionstypen <i>getstate</i>, werden
                meist englische Werte ausgegeben oder solche die nicht "toll"
                aussehen. Mit dem sar Wert kann ein solches Reading ersetzt
                werden.<br>
                <b>Beispiele:</b><br>
                <ul>
                    <li><i>sar:on=an,sar:off=aus</i><br>
                        Readingergebnisse welche <i>on</i> sind werden durch 
                        <i>an</i> ersetzt.
                        <i>off</i> wird duch <i>aus</i> ersetzt.<br>
                        Befehl: <i>Wie ist der Status der Deckenlampe</i><br>
                        Antwort: <i>Die Deckenlampe ist an</i><br>
                </ul>
            </ul>
            <ul>
                <li><b><u>Sonstige befehle:</u></b><br>
                <ul>
                    <li><i>AllRestrictedMapping</i><br>
                        Der Befehl begrenzt alle Möglichkeiten ein Device zu
                        steuern oder abzufragen auf solche die als Mapping
                        Befehle angelegt sind. Die
                        Mapping Befehle müssen mindestens als Typ 1 im Attribut
                        <i>TEERKOExpert</i> vorhanden sein.<br>
                        Z.b sorgt <i>attr &lt;device&gt; TEERKOExpert 
                        map:seton,map:setoff,map:getstate,AllRestrictedMapping</i> 
                        dafür das das Gerät ausschließlich ein- und ausgeschaltet
                        werden darf.</li>
            </ul>
        </ul><br>
    </ul>
    </ul>
    <a name="TEERKOuserdef"></a>
    <b>Benutzerdefinierte Befehle</b>
    <ul>
        Die Benutzerdefinierten Befehle ermöglichen es die Erkennung von TEERKO
        zu umgehen. Somit können weitere Szenarien angelegt werden die von TEERKO
        umgesetzt werden.<br>
        Die Benutzerdefinierten Befehle werden in einer Datei angelegt.
        Diese Datei kann z.B. mit dem internen FHEM Editor erstellt werden.
        Sollte die Datei mit dem internen Editor geschrieben worden sein kann Sie
        mit "Save As" z.b mit dem Namen "TEERKOUserDef.conf" abgespeichert 
        werden.<br>Mit <code>set &lt;TEERKODevice&gt; ReadUserFile /opt/fhem/FHEM/TEERKOUserDef.conf</code>
        wird die Datei in das TEERKO Device eingelesen und gespeichert.<br><br>
        <a name="TEERKOuserdefstructure"></a>
        <b>Aufbau der Datei</b><br>
        <code>[command]<br>
        in=lichtszenario.*(gemütlich|aus|an|party).*wohnzimmer<br>
        out=Ich stelle im Wohnzimmer das Lichtszenario %1% ein.<br>
        fhem=set lightscene scene %1%<br>
        <br>
        [command]<br>
        in=ich.*zuhause<br>
        out=Hallo. Schön das du da bist.<br>
        fhem=set light1 on;sleep 3;set coffemaker on;set livingroomlight pct 50<br>
        <br>
        [command]<br>
        in=wie.*wetter<br>
        out=Die Temperatur beträgt %weatherdevice%. Die Feuchtigkeit beträgt 
        %weatherdevice:humidity% Prozent.
        Das Wetter ist %weatherdevice:icon:rainy=regnerisch,cloudy=wolkig,stormy=So richtig mies%<br>
        <br>
        [command]<br>
        in=...<br>
        out=...<br>
        fhem=...<br>
        <br>
        ...<br>
        <br>
        <br>
        </code>
        <b>Parts eines neuen Kommandos</b><br>
        <ul>
            <li>in=<br>
            (Pflichtangabe) Der Satz (RegExpr erlaubt) wird mit dem
            eingegebenen Befehl abgeglichen. Sollte es zu einer Übereinstimmung 
            kommen wird TEERKO keinen internen Abgleich mehr machen sondern den
            benutzerdefinierten Befehl akzeptieren.</li>
            <li>out=<br>
            (Optionale Angabe) Die Antwort die TEERKO auf den Befehl geben soll.
            Wird keine Antwort angegeben antwortet TEERKO mit "Ok."</li>
            <li>fhem=<br>
            (Optionale Angabe) FHEM Kommandos die nach erkennen des Befehls 
            ausgeführt werden sollen. Kein Perl Code.</li>
        </ul><br>
        <b>RegExp Captures</b><br>
        <ul>
            Sollten in dem in= Part durch RegExp Captures auftreten können diese
            unter Angabe der gefundenen Platzierung in out= und fhem= wiederverwendet
            werden. Siehe Aufbau Bsp. 1
        </ul><br>
        <b>Readings in out=</b><br>
        <ul>
            Es können in der Ausgabe auch Readings eingebunden werden. Siehe
            Aufbau Bsp. 3.<br>
            Diese Readings können auch durch andere Werte ersetzt werden.
            <ul>
                <li>%weatherdevice%<br>
                    Liest das Reading state aus dem Device weatherdevice</li>
                <li>%weatherdevice:humidity%<br>
                    Liest das Reading humidity aus dem Device weatherdevice</li>
                <li>%weatherdevice:icon:rainy=regnerisch,cloudy=wolkig%<br>
                    Liest das Reading icon aus dem Device weatherdevice und ersetzt
                    ein mögliches vorkommen von "rainy" durch "regnerisch" und 
                    "cloudy" durch "wolkig" und "stormy" durch "so richtig mies"</li>
            </ul>
        </ul><br>
    </ul>
    <br>
</ul>
=end html_DE
=cut
