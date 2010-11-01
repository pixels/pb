//
//  Define.h
//  WePublish
//
//  Created by Yusuke Kikkawa on 10/06/28.
//  Copyright 2010 3di. All rights reserved.
//

// Flag
#define USE_WEBKIT false
#define PAGING_BY_TAP true

// Page size
#define WINDOW_AW 768
#define WINDOW_AH 1024
#define WINDOW_BW 1024
#define WINDOW_BH 768

// Page Margin
#define PAGE_MARGIN_TOP 0
#define PAGE_MARGIN_BOTTOM 0
#define PAGE_MARGIN_LEFT 0
#define PAGE_MARGIN_RIGHT 0

#define SHADOW_RED 1.0f
#define SHADOW_GREEN 1.0f
#define SHADOW_BLUE 1.0f

#define SHADOW_ALPHA 0.25f
#define TOP_SHADOW_ALPHA 0.2f
#define TOP_OVERLAY_ALPHA 0.6f

#define FACE_PAGE_SHADOW_ALPHA 0.4f

// Set speed of curling page
#define CURL_BOOST 1.5f

// Max scale
#define MAX_ZOOM_SCALE 1.0f
#define MIN_ZOOM_SCALE 1.0f

#define REVERSE_PAGE_OPACITY 0.5f

#define PAGING_WAIT_TIME 0.003f

#define CURL_SPAN 0.01f

#define PAGE_CHANGE_TRIGGER_MARGIN 20.0f

#define CENTER_SHADOW_WIDTH 12
#define TOP_SHADOW_WIDTH 30
#define BOTTOM_SHADOW_WIDTH 100

// Event
#define APP_FINISH_EVENT @"app_finish_event"
#define PAGE_CHANGE_EVENT @"page_change_event"           // ページの切り替わり
#define BOOKMARK_SAVE_EVENT @"bookmark_save_event"       // しおり保存
#define READ_TO_SELECT_EVENT @"read_to_select_event"     // 読む画面から選択画面へ

#define XML_DIRECTORY @"xml"
#define BOOK_DIRECTORY @"xml/book"
#define BOOK_EXTENSION @"png"
#define LIST_FILENAME @"list.xml"
#define USER_FILENAME @"user.xml"
#define BOOKMARK_FILENAME @"bookmark.xml"
#define USER_NAME @"name"
#define USER_PASS @"pass"
#define BOOKMARK_UUID @"uuid"
#define BOOKMARK_PAGE @"page"
