/**
 * Custom error class for script loading failures.
 * @extends Error
 */
class ScriptLoaderError extends Error {
  /**
   * Creates a new ScriptLoaderError.
   * @param {string} message - The error message.
   * @param {string} src - The source URL of the script that failed to load.
   */

  constructor(message, src) {
    super(message);
    this.name = 'ScriptLoaderError';
    this.src = src;
  }

  /**
   * Gets detailed error information.
   * @returns {string} A string containing the error details.
   */
  getErrorDetails() {
    return `Failed to load script from source: ${this.src}`;
  }
}

/**
 * Creates a new script element with the specified attributes.
 * @param {string} src - The source URL of the script.
 * @param {Object} options - Options for configuring the script element.
 * @param {string} [options.type='text/javascript'] - The type of the script.
 * @param {boolean} [options.async=true] - Whether the script should load asynchronously.
 * @param {boolean} [options.defer] - Whether the script execution should be deferred.
 * @param {string} [options.crossOrigin] - The CORS setting for the script.
 * @param {boolean} [options.noModule] - Whether the script should not be treated as a JavaScript module.
 * @param {string} [options.referrerPolicy] - The referrer policy for the script.
 * @param {string} [options.id] - The id attribute for the script element.
 * @param {Object} [options.attrs] - Additional attributes to set on the script element.
 * @returns {HTMLScriptElement} The created script element.
 */
const createScriptElement = (src, options) => {
  const el = document.createElement('script');
  el.type = options.type || 'text/javascript';
  el.async = options.async !== false;
  el.src = src;

  const properties = [
    'defer',
    'crossOrigin',
    'noModule',
    'referrerPolicy',
    'id',
  ];

  properties.forEach(property => {
    if (options[property]) el[property] = options[property];
  });

  Object.entries(options.attrs || {}).forEach(([name, value]) =>
    el.setAttribute(name, value)
  );

  return el;
};

/**
 * Finds an existing script element with the specified source URL.
 * @param {string} src - The source URL to search for.
 * @returns {HTMLScriptElement|null} The found script element, or null if not found.
 */
const findExistingScript = src => {
  return document.querySelector(`script[src="${src}"]`);
};

/**
 * Loads a script asynchronously and returns a promise.
 * @param {string} src - The source URL of the script to load.
 * @param {Object} options - Options for configuring the script element.
 * @param {string} [options.type='text/javascript'] - The type of the script.
 * @param {boolean} [options.async=true] - Whether the script should load asynchronously.
 * @param {boolean} [options.defer] - Whether the script execution should be deferred.
 * @param {string} [options.crossOrigin] - The CORS setting for the script.
 * @param {boolean} [options.noModule] - Whether the script should not be treated as a JavaScript module.
 * @param {string} [options.referrerPolicy] - The referrer policy for the script.
 * @param {string} [options.id] - The id attribute for the script element.
 * @param {Object} [options.attrs] - Additional attributes to set on the script element.
 * @returns {Promise<HTMLScriptElement|boolean>} A promise that resolves with the loaded script element,
 *                                               or false if the script couldn't be loaded.
 * @throws {ScriptLoaderError} If the script fails to load.
 */
export async function loadScript(src, options) {
  return new Promise((resolve, reject) => {
    if (typeof window === 'undefined' || !window.document) {
      resolve(false);
      return;
    }

    let el = findExistingScript(src);

    if (!el) {
      el = createScriptElement(src, options);
      document.head.appendChild(el);
    } else if (el.hasAttribute('data-loaded')) {
      resolve(el);
      return;
    }

    const loadError = new ScriptLoaderError(`Failed to load script`, src);
    const abortError = new ScriptLoaderError(`Script loading aborted`, src);

    el.addEventListener('error', () => reject(loadError));
    el.addEventListener('abort', () => reject(abortError));
    el.addEventListener('load', () => {
      el.setAttribute('data-loaded', 'true');
      resolve(el);
    });
  });
}
