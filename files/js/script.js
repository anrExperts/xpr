/*
 * Javascript for the xpr app
 *
 * @author emchateau & sardinecan (ANR Experts)
 * @since 2020-05
 * @licence GNU http://www.gnu.org/licenses
 * @version 0.2
 *
 * xpr is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 */

/*
 * Filter lists by input
 */
// Get input element
    let filterInput = document.getElementById('filter');
// Add event listener
filterInput.addEventListener('keyup', filterNames);
function filterNames() {
    // Get value of input
    let filterValue = document.getElementById('filter').value.toUpperCase();

    // Get names ul
    let ul = document.getElementById('list');
    // Get list from ul
    let li = ul.querySelectorAll('li');

    // Loop through collection-item list
    for (let i = 0; i < li.length; i++) {
        let a = li[i].getElementsByTagName('h3')[0];
        // If matched
        if (a.innerHTML.toUpperCase().indexOf(filterValue) > -1) {
            li[i].style.display = '';
        } else {
            li[i].style.display = 'none';
        }
    }
}