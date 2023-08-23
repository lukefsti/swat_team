import logging
import json
import time
from pynput import keyboard, mouse
import win32gui
import threading

# Configuration
log_dir = ""
logging.basicConfig(filename=(log_dir + "activity_log.txt"), level=logging.DEBUG, format='%(message)s')

# Global State
LAST_KEY_TIME = time.time()
LAST_ACTIVE_TIME = time.time()
CURRENT_WINDOW_TITLE = None
WINDOW_ACTIVE_START_TIME = None
IS_MOUSE_DRAGGING = False
AGGREGATED_MOUSE_MOVEMENTS = []

# User Activity: Idle Time Detection Configuration
IDLE_TIME_THRESHOLD = 10  # 10 seconds

def get_active_window_info():
    try:
        hwnd = win32gui.GetForegroundWindow()
        title = win32gui.GetWindowText(hwnd)
        rect = win32gui.GetWindowRect(hwnd)
        width, height = rect[2] - rect[0], rect[3] - rect[1]
        return title, width, height
    except Exception as e:
        logging.error(f"Error getting active window info: {e}")
        return None, None, None

def log_event(event_type, data):
    try:
        window_title, width, height = get_active_window_info()
        window_details = get_active_window_details()
        log_data = {
            'timestamp': time.strftime('%Y-%m-%d %H:%M:%S', time.gmtime(time.time())),
            'event_type': event_type,
            'active_window': {
                'title': window_title or "Unknown",
                'resolution': f'{width}x{height}' if width and height else "Unknown",
                'details': window_details or {}
            },
            'data': data
        }
        logging.info(json.dumps(log_data, ensure_ascii=False))
    except Exception as e:
        logging.error(f"Error logging event {event_type}: {e}")


def on_move(x, y):
    global LAST_ACTIVE_TIME, AGGREGATED_MOUSE_MOVEMENTS, IS_MOUSE_DRAGGING
    try:
        AGGREGATED_MOUSE_MOVEMENTS.append((x, y))
        if not IS_MOUSE_DRAGGING and time.time() - LAST_ACTIVE_TIME > 10:  # 10 seconds
            if AGGREGATED_MOUSE_MOVEMENTS:
                average_x = sum([coord[0] for coord in AGGREGATED_MOUSE_MOVEMENTS]) / len(AGGREGATED_MOUSE_MOVEMENTS)
                average_y = sum([coord[1] for coord in AGGREGATED_MOUSE_MOVEMENTS]) / len(AGGREGATED_MOUSE_MOVEMENTS)
                log_event('average_mouse_position_10s', {'x': average_x, 'y': average_y})
                AGGREGATED_MOUSE_MOVEMENTS = []
            LAST_ACTIVE_TIME = time.time()

        LAST_ACTIVE_TIME = time.time()
        check_for_idle()
    except Exception as e:
        logging.error(f"Error during mouse move: {e}")

def check_for_idle():
    global LAST_ACTIVE_TIME
    try:
        idle_duration = time.time() - LAST_ACTIVE_TIME
        if idle_duration > IDLE_TIME_THRESHOLD:
            log_event('idle', {'duration': idle_duration})
            LAST_ACTIVE_TIME = time.time()
    except Exception as e:
        logging.error(f"Error during idle check: {e}")

def on_key_press(key):
    global LAST_KEY_TIME, LAST_ACTIVE_TIME
    try:
        time_since_last_key = time.time() - LAST_KEY_TIME
        LAST_KEY_TIME = time.time()
        key_data = str(key.char) if hasattr(key, 'char') else str(key)
        log_event('keypress', {'key': key_data, 'time_since_last_key': time_since_last_key})

        LAST_ACTIVE_TIME = time.time()
        check_for_idle()
    except Exception as e:
        logging.error(f"Error during on_key_press check: {e}")

def on_click(x, y, button, pressed):
    global LAST_ACTIVE_TIME, IS_MOUSE_DRAGGING, AGGREGATED_MOUSE_MOVEMENTS  # added AGGREGATED_MOUSE_MOVEMENTS here
    try:
        if pressed:
            log_event('mouse_click_down', {'x': x, 'y': y, 'button': str(button)})
            IS_MOUSE_DRAGGING = True
        else:
            log_event('mouse_click_up', {'x': x, 'y': y, 'button': str(button)})
            if IS_MOUSE_DRAGGING:
                log_event('mouse_drag', {'path': AGGREGATED_MOUSE_MOVEMENTS, 'end_x': x, 'end_y': y})
                AGGREGATED_MOUSE_MOVEMENTS = []
            IS_MOUSE_DRAGGING = False

        LAST_ACTIVE_TIME = time.time()
        check_for_idle()
    except Exception as e:
        logging.error(f"Error during on_click check: {e}")

def get_active_window_details():
    try:
        hwnd = win32gui.GetForegroundWindow()
        title = win32gui.GetWindowText(hwnd)
        class_name = win32gui.GetClassName(hwnd)
        rect = win32gui.GetWindowRect(hwnd)
        location = {'top_left': (rect[0], rect[1]), 'bottom_right': (rect[2], rect[3])}
        parent_hwnd = win32gui.GetParent(hwnd)
        parent_title = win32gui.GetWindowText(parent_hwnd) if parent_hwnd else None
        child_windows = []

        def enum_child(hwnd, _):
            child_windows.append((hwnd, win32gui.GetWindowText(hwnd)))

        win32gui.EnumChildWindows(hwnd, enum_child, None)

        window_details = {
            'title': title,
            'class_name': class_name,
            'location': location,
            'parent_title': parent_title,
            'children': [title for _, title in child_windows if title]
        }
        
        return window_details
    except Exception as e:
        logging.error(f"Error during get_active_window_details check: {e}")
        return None

def check_for_active_window_change():
    global CURRENT_WINDOW_TITLE, WINDOW_ACTIVE_START_TIME
    try:
        title, _, _ = get_active_window_info()
        if CURRENT_WINDOW_TITLE != title:
            log_window_active_duration()
            CURRENT_WINDOW_TITLE = title
            WINDOW_ACTIVE_START_TIME = time.time()
    except Exception as e:
        logging.error(f"Error during check_for_active_window_change: {e}")

def log_window_active_duration():
    global CURRENT_WINDOW_TITLE, WINDOW_ACTIVE_START_TIME
    try:
        if CURRENT_WINDOW_TITLE:
            duration = time.time() - WINDOW_ACTIVE_START_TIME
            log_event('window_active_duration', {'window_title': CURRENT_WINDOW_TITLE, 'duration': duration})
    except Exception as e:
        logging.error(f"Error during log_window_active_duration: {e}")

def monitor_active_window():
    while True:
        try:
            check_for_active_window_change()
            time.sleep(1)
        except Exception as e:
            logging.error(f"Error during active window monitoring: {e}")

window_monitor_thread = threading.Thread(target=monitor_active_window, daemon=True)  # Make thread daemon
window_monitor_thread.start()

key_listener = None
mouse_listener = None

try:
    log_event('session_start', {})

    with keyboard.Listener(on_press=on_key_press, on_release=None) as key_listener, \
         mouse.Listener(on_click=on_click, on_move=on_move, on_scroll=None) as mouse_listener:
        key_listener.join()
        mouse_listener.join()

    log_event('session_end', {})
except Exception as e:
    logging.error(f"Error occurred: {e}")
    log_event('session_error', {'error': str(e)})
finally:
    # Graceful Shutdown
    if key_listener:
        key_listener.stop()
    if mouse_listener:
        mouse_listener.stop()