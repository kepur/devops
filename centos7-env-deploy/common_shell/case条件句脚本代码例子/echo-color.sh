#!/bin/bash

RED_COLOR='\E[1;31m'
GREEN_COLOR='\E[1;32m'
YELOW_COLOR='\E[1;33m'
BLUE_COLOR='\E[1;34m'
PINK='\E[1;35m'
RES='\E[0m'

echo -e  "${RED_COLOR}======red color======${RES}"
echo -e  "${YELOW_COLOR}======yelow color======${RES}"
echo -e  "${BLUE_COLOR}======green color======${RES}"
echo -e  "${GREEN_COLOR}======green color======${RES}"
echo -e  "${PINK}======pink color======${RES}"

echo "#############################################################"

SETCOLOR_SUCCESS="echo -en \\033[1;32m"
SETCOLOR_FAILURE="echo -en \\033[1;31m"
SETCOLOR_WARNING="echo -en \\033[1;33m"
SETCOLOR_NORMAL="echo -en \\033[0;39m"

echo ----oldboy trainning-----   &&  $SETCOLOR_SUCCESS
echo ----oldboy trainning-----   &&  $SETCOLOR_FAILURE
echo ----oldboy trainning-----   &&  $SETCOLOR_WARNING
echo ----oldboy trainning-----   &&  $SETCOLOR_NORMAL
